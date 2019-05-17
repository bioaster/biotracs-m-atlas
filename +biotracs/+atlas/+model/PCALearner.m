% BIOASTER
%> @file		PCALearner.m
%> @class		biotracs.atlas.model.PCALearner
%> @link		http://www.bioaster.org
%> @copyright	Copyright (c) 2014, Bioaster Technology Research Institute (http://www.bioaster.org)
%> @license		BIOASTER
%> @date		2015

classdef PCALearner < biotracs.atlas.model.BaseDecompLearner
    
    properties(Constant)
    end
    
    properties(Dependent)
    end
    
    events
    end
    
    % -------------------------------------------------------
    % Public methods
    % -------------------------------------------------------
    
    methods
        
        % Constructor
        function this = PCALearner()
            this@biotracs.atlas.model.BaseDecompLearner();
            % enhance outputs specs
            this.addOutputSpecs({...
                struct(...
                'name', 'Result',...
                'class', 'biotracs.atlas.model.PCALearnerResult' ...
                )...
             });
        end
        
    end
    
    % -------------------------------------------------------
    % Private methods
    % -------------------------------------------------------
    
    methods(Access = protected)
        
        function doLearn( this, X0, varargin )
            % SVD decomposition
            [U, S, V] = svd( X0, 'econ' );

            ncomp = this.config.getParamValue('NbComponents');
            ncomp = min(size(S,2), ncomp);
            [m,n] = size(X0);
            
            % R2X
            stats.R2X = zeros(ncomp,1);
            stats.adjR2X = zeros(ncomp,1);
            
            % RMSE
            stats.XRmsee = zeros(ncomp+1,1);
            XSStot = sum(sum(abs(X0).^2, 1));     
            stats.XRmsee(1) = sqrt(XSStot) / (m*n);

            for i=1:ncomp
                X0pred = U*S(:,1:i)*V(:,1:i)';
                
                %R2X, RMSEE X, R2X ...
                XSSres = sum(sum(abs(X0 - X0pred).^2, 1));
                stats.XRmsee(i+1) = sqrt(XSSres) / (m*n);
                stats.R2X(i) = 1 - XSSres ./ XSStot;
                stats.adjR2X(i) = 1 - (1-stats.R2X(i))*(m-1)/(m-ncomp-1);
            end

            XS = U * S;
            varExp = diag(S)';
            varExp = 100 * varExp ./ sum(varExp);
            
            result = this.getOutputPortData('Result');
            result.setXVarExplainedData( varExp(1:ncomp) );
            result.setXScoreData(XS(:,1:ncomp), this.getTrainingInstanceNames());
            result.setXLoadingData(V(:,1:ncomp), this.getVariableNames());
            result.setStatData( stats, this.getResponseNames(), 'PC' );
            
            this.setOutputPortData('Result', result);
        end
        
        function doLearnCv( varargin )
            %error('The cross-validation algorithm is not yet implemented for pca')
        end
        
        function doLearnPerm( varargin )
            %error('The cross-validation algorithm is not yet implemented for pca')
        end
        
    end
    
    
end
