function [nfactor,Tb,Pb,Wb,Wt,Tt,Ub,Qb,QQb,Wu,Tu,params,XX,YY]=sMBbpls_CV(params,nfold,outFile)
% function [nfactor,Tb,Pb,Wb,Wt,Tt,Ub,Qb,QQb,Wu,Tu,params,XX,YY]=sMBbpls_CV(params,nfold,outFile)
% Please assign X, Xin, Y, Yin as global variables, before using this function.
% in  : 
% X (objects x all X-variables) single, augmented X-data-block
% Xin (number of X-blocks x 2) = begin to end variable index for this X-block; index for X-block
% Y (objects x all Y-variables) single, augmented Y-data-block
% Yin (number of Y-blocks x 2) = begin to end variable index for this Y-block; index for Y-block
% params = a structure containing all necessary parameters needed to run this program.
% nfold = number of folds for cross-validation.
% outFile = text file name of modules found.
%
% out : 
% nfactor number of factors identified
% Tb (objects x number of X-blocks) block scores, [t1-block-1 t1-block-2 ...t2-block-1...]
% Pb (X-variables x nLV) X-block loadings
% Wb (X-variables x nLV) X-block weigths
% Wt (number of X-blocks x nLV) X-block super weights
% Tt (objects x nLV) X-block super scores
% Ub (objects x number of Y-blocks.max(nLV)) Y-block scores
% Qb (Y-variables x nLV) Y-block weights
% Wu (number of Y-blocks x nLV) Y-block super weights
% Tu (objects x nLV) Y-block super scores
%
if nargin == 0
   help sMBbpls_CV
   return
end

global ZERO
ZERO=eps;
global X Xin Y Yin
%global Tb Pb Wb Wt Tt Ub Qb QQb Wu Tu
%global nfactor
[n,m] = size(X);
nbX = size(Xin,1); % nbX : #blocks in X
[n,p] = size(Y);
nbY = size(Yin,1); % nbY : #blocks in Y
nLV = params.nfactor*ones(nbX,1);
[maxLV,maxb] = max(nLV);
nparameter = length(params.param);
Tb = zeros(n,maxLV*nbX);
Pb = zeros(m,maxLV);
Wb = zeros(m,maxLV);
Wt = zeros(nbX,maxLV);
Tt = zeros(n,maxLV);
Ub = zeros(n,maxLV*nbY);
Qb = zeros(p,maxLV);
QQb = zeros(p,maxLV);
Wu = zeros(nbY,maxLV);
Tu = zeros(n,maxLV);
params.cv_scores = zeros(nparameter,maxLV);
params.randRowPartitions=rand_nFold(n,nfold);

nfactor = 0;
for a=1:maxLV
    fprintf('Latent Variable %d\n      ', a);
    [param_idx,cv_scores_onefactor]=estimate_sparsity_oneFactor(X,Xin,Y,Yin,params);
    [success,oneF.Tb,oneF.Pb,oneF.Wb,oneF.Wt,oneF.Tt,oneF.Ub,oneF.Qb,...
        oneF.QQb,oneF.Wu,oneF.Tu,XX,YY]=sMBbpls_oneFactor(X,Xin,Y,Yin,params.param{param_idx},outFile);
    if (success),
        nfactor = nfactor+1;
        X=XX; Y=YY;
        for aa=1:nbX,
            coli = (a-1)*nbX+aa;
            Tb(:,coli) = oneF.Tb(:,aa);
        end
        Wb(:,a) = oneF.Wb;
        Pb(:,a) = oneF.Pb;
        Wt(:,a) = oneF.Wt;
        Tt(:,a) = oneF.Tt;
        for aa=1:nbY,
            coli = (a-1)*nbY+aa;
            Ub(:,coli) = oneF.Ub(:,aa);
        end
        Qb(:,a) = oneF.Qb;
        QQb(:,a) = oneF.QQb;
        Wu(:,a) = oneF.Wu;
        Tu(:,a) = oneF.Tu;
        
        params.paramsidx_used(a,1)=param_idx;
        params.cv_scores(:,a)=cv_scores_onefactor;
    end
end
XX=X; YY=Y;

