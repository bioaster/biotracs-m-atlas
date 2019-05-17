function [R] = HotellingT2(X,varargin)
%Hotelling T-Squared testing procedures for multivariate samples.
%
%   Syntax: function [HotellingT2] = HotellingT2(X,alpha)
%
%     Inputs:
%          X - multivariate data matrix 
%                   - numeric matrix or
%                   - cell of 2 matrices for two-group means comparison.
%
%     Outputs:
%          It depends of the Hotelling's T-Squared multivariate test of interest,
%          being able to be:
%
%            |-One-sample
%            |                          |-Homoskedasticity (to test)
%            |            |-Independent |
%            |            |             |-Heteroskedasticity (to test)
%            |-Two-sample |
%                         |
%                         |-Dependent
%
%          Each case calls to a corresponding function that contains a complete
%          explanation.
%
%  Created by A. Trujillo-Ortiz and R. Hernandez-Walls
%             Facultad de Ciencias Marinas
%             Universidad Autonoma de Baja California
%             Apdo. Postal 453
%             Ensenada, Baja California
%             Mexico.
%             atrujo@uabc.mx
%             And the special collaboration of the post-graduate students of the 2002:2
%             Multivariate Statistics Course: Karel Castro-Morales, Alejandro Espinoza-Tenorio,
%             Andrea Guia-Ramirez.
%
%  Copyright (C) December 2002.
%

param = inputParser;
param.addParameter( 'IndependentSamples', [], @(x)(ismepty(x) || islogical(x)) );
param.addParameter( 'ExpectedMean',[], @isnumeric );
param.addParameter( 'VarianceHomogeneityPValue', 0.05, @(x)(isnumeric(x) || x > 0) );
param.addParameter( 'HotellingEllipseConfidence', 0.95, @(x)(isnumeric(x) && x > 0 && x < 1) );
param.KeepUnmatched = true;
param.parse(varargin{:});

if nargin < 1
    error('Requires at least one input argument.');
end

if isnumeric(X) || (iscell(X) && length(X) == 1)
    if iscell(X), X = X{1}; end
    [n,p] = size(X);
    
    if ~isempty(param.Results.ExpectedMean)
        mu = param.Results.ExpectedMean;
    else
        mu = zeros([1,p]);
    end
    
    R = hotelling.T2Hot1(X, mu);
    
    % compute confidence interval
    S=cov(X);
    [U,S,~] = svd(S);
    
    ncomp = p;
    
    if p == 2
        c = circle(0,0,1);
    else
        nbFaces = 128;
        [x,y,z] = sphere(nbFaces);
        c = [x(:), y(:), z(:)]; %compact coordinates
    end
    
    z = 1.96 * c;                                                                           %to have 95% ellipse
    k = size(z,1);

    R.ellipse = (U*S(:,1:ncomp)^0.5*z')' + repmat(mu,k,1);
    
    t2 = finv(param.Results.HotellingEllipseConfidence, p , n-p) * (n-1)*p/(n-p);         %to have 95% ellipse for the Fisher(n,n-p) distribution
    t = sqrt(t2);
    z = t * c;
    R.ellipseT2 = (U*S(:,1:ncomp)^0.5*z')' + repmat(mu,k,1);
    
    if p == 3
        %expand coordinates
        R.ellipse = {
            reshape( R.ellipse(:,1), [nbFaces, nbFaces]+1 ),...
            reshape( R.ellipse(:,2), [nbFaces, nbFaces]+1 ),...
            reshape( R.ellipse(:,3), [nbFaces, nbFaces]+1 )...
        };
        R.ellipseT2 = { ...
            reshape( R.ellipseT2(:,1), [nbFaces, nbFaces]+1 ),...
            reshape( R.ellipseT2(:,2), [nbFaces, nbFaces]+1 ),...
            reshape( R.ellipseT2(:,3), [nbFaces, nbFaces]+1 )...
        };
    end
    
elseif iscell(X) && length(X) == 2
    %Concatenate X{i} to create a block matrix for other functions
    n = size(X{1},1);
    X = [ones(n,1), X{1}, 2*ones(n,1), X{2}];
    
    if param.Results.IndependentSamples;
        disp('The covariance matrix homogeneity will be tested...');
        MBoxR = hotelling.MBoxtest(X);
        %dc = input('Do they were significant? (y/n): ','s');
        if MBoxR.pvalue < param.Results.VarianceHomogeneityPValue
            fprintf('Covariances are homogeneous (p-value = %1.5f)%', MBoxR.pvalue);
            disp('Use Hotelling''s T-Squared test for two multivariate independent samples with unequal covariance matrices.');
            R = hotelling.T2Hot2ihe(X);
        else
            fprintf('Covariances are not homogeneous (p-value = %1.5f)%', MBoxR.pvalue);
            disp('Use Hotelling''s T-Squared test for two multivariate independent samples with equal covariance matrices.');
            R = hotelling.T2Hot2iho(X);
        end;
    else
        R = hotelling.T2Hot2d(X);
    end
else
    error('Wrong data')
end

return;


function [out] = circle(x0,y0,r)
    th = 0:pi/50:2*pi;
    x = r * cos(th') + x0;
    y = r * sin(th') + y0;
    out = [x,y];
return
