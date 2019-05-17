function [success,Tb,Pb,Wb,Wt,Tt,Ub,Qb,QQb,Wu,Tu,X,Y]=sMBbpls_oneFactor(X,Xin,Y,Yin,param,outFile)
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
% Tb (objects x number of X-blocks) block scores, [t1-block-1 t1-block-2 ...t2-block-1...]
% Pb (X-variables x 1)) X-block loadings
% Wb (X-variables x 1) X-block weigths
% Wt (number of X-blocks x 1) X-block super weights
% Tt (objects x 1) X-block super scores
% Ub (objects x number of Y-blocks) Y-block scores
% Qb (Y-variables x 1) Y-block weights
% Wu (number of Y-blocks x 1) Y-block super weights
% Tu (objects x 1) Y-block super scores
%
global ZERO
[n,m] = size(X);
nbX = size(Xin,1); % nbX : #blocks in X
[n,p] = size(Y);
nbY = size(Yin,1); % nbY : #blocks in Y
% Precision for convergence
tol = param.epsilon;
maxiter = param.maxIter;
% Thresholding
thrd_w=param.thrXc;
thrd_t=param.thrXr;
thrd_c=param.thrYc;
thrd_u=param.thrYr;

Tb = zeros(n,nbX);
Pb = zeros(m,1);
Wb = zeros(m,1);
Wt = zeros(nbX,1);
Tt = zeros(n,1);
Ub = zeros(n,1*nbY);
Qb = zeros(p,1);
QQb = zeros(p,1);
Wu = zeros(nbY,1);
Tu = zeros(n,1);

success = 0;
iter = 0;
Tu = ones(size(Y(:,1)));
Tt = ones(size(X(:,Xin(1,1))));
t_old = Tt*100;
while (sum((t_old - Tt).^2) > tol) & (iter < maxiter)
    iter = iter + 1;
    t_old = Tt;
    for aa=1:nbX
        rowi = Xin(aa,1):Xin(aa,2);
        coli = aa;
        Wb(rowi) = thresholding(X(:,rowi)'*Tu, thrd_w(aa), 'Wb(rowi)'); Wb(rowi) = normaliz(Wb(rowi)); %Wb(rowi,a) = X(:,rowi)'*Tu(:,a)/(Tu(:,a)'*Tu(:,a)); Wb(rowi,a) = Wb(rowi,a)/norm(Wb(rowi,a));
        str=['Wb(rowi),Xblock=' num2str(aa)];
        err=NaNerrorCheck(Wb(rowi), str);
        if (err), return; end
        Tb(:,coli) = thresholding(X(:,rowi)*Wb(rowi), thrd_t, 'Tb(:,coli)'); Tb(:,coli) = normaliz(Tb(:,coli)); %Tb(:,coli) = X(:,rowi)*Wb(rowi,a)/(Wb(rowi,a)'*Wb(rowi,a));
        err=NaNerrorCheck(Tb(:,coli), ['Tb(:,coli),Xblock=' num2str(aa)]);
        if (err), return; end
    end
    index = 1:nbX;
    Wt = Tb(:,index)'*Tu; Wt = normaliz(Wt); %Wt(:,a) = Tb(:,index)'*Tu(:,a)./(Tu(:,a)'*Tu(:,a)); Wt(:,a) = Wt(:,a)/norm(Wt(:,a));
    err=NaNerrorCheck(Wt, 'Wt');
    if (err), return; end
    Tt = Tb(:,index)*Wt; Tt = normaliz(Tt); %Tt(:,a) = Tb(:,index)*Wt(:,a)/(Wt(:,a)'*Wt(:,a));
    err=NaNerrorCheck(Tt, 'Tt');
    if (err), return; end
    for aa=1:nbY
        rowi = Yin(aa,1):Yin(aa,2);
        coli = aa;
        Qb(rowi) = thresholding(Y(:,rowi)'*Tt/(Tt'*Tt), thrd_c(aa), 'Qb(rowi)'); Qb(rowi)=normaliz(Qb(rowi)); %Qb(rowi,a) = Y(:,rowi)'*Tt(:,a)/(Tt(:,a)'*Tt(:,a));
        NaNerrorCheck(Qb(rowi), ['Qb(rowi),Yblock=' num2str(aa)]);
        if (err), return; end
        Ub(:,coli) = thresholding(Y(:,rowi)*Qb(rowi)/(Qb(rowi)'*Qb(rowi)),thrd_u,'Ub(:,coli)'); Ub(:,coli) = normaliz(Ub(:,coli));
        NaNerrorCheck(Ub(:,coli), ['Ub(:,coli),Yblock=' num2str(aa)]);
        if (err), return; end
    end
    index = 1:nbY;
    Wu = Ub(:,index)'*Tt; Wu = normaliz(Wu);%Wu(:,a) = Ub(:,index)'*Tt(:,a)/(Tt(:,a)'*Tt(:,a)); Wu(:,a) = Wu(:,a)/norm(Wu(:,a));
    NaNerrorCheck(Wu, 'Wu');
    if (err), return; end
    Tu = Ub(:,index)*Wu; Tu=normaliz(Tu); %Tu(:,a) = Ub(:,index)*Wu(:,a)/(Wu(:,a)'*Wu(:,a));
    NaNerrorCheck(Tu, 'Tu');
    if (err), return; end
end

if iter == maxiter
    s = ['WARNING: maximum number of iterations (' num2str(maxiter) ') reached before convergence'];
    disp(s)
end

for aa=1:nbX
    rowi = Xin(aa,1):Xin(aa,2);
    coli = aa;
    Pb(rowi) = halfthresholding(X(:,rowi)'*Tb(:,coli)/(Tb(:,coli)'*Tb(:,coli)),thrd_w(aa),'Pb(rowi)');
    NaNerrorCheck(Pb(rowi), ['Pb(rowi),Xblock=' num2str(aa)]);
    X(:,rowi) = X(:,rowi) - Tb(:,coli)*Pb(rowi)';
    NaNerrorCheck(X(:,rowi), ['X(:,rowi),Xblock=' num2str(aa)]);
end
for aa=1:nbY
    rowi = Yin(aa,1):Yin(aa,2);
    coli = aa;
    QQb(rowi) = halfthresholding(Y(:,rowi)'*Ub(:,coli)/(Ub(:,coli)'*Ub(:,coli)),thrd_c(aa),'QQb(rowi)');
    Y(:,rowi) = Y(:,rowi) - Ub(:,coli)*QQb(rowi)';
end
success = 1;

if (nargin==6), % output this co-module to a file
    % get co-modules from X and Y
    ti = find(Tt)'; % selected samples in X
    ui = find(Tu)'; % selected samples in Y
    selected_samples=intersect(ti,ui);
    if (isempty(selected_samples)), return; end
    outStr = mat2str_wenyuan(selected_samples);
    outStrCnt = num2str(length(selected_samples));
    for aa=1:nbX
        rowi = Xin(aa,1):Xin(aa,2);
        wi = find(Wb(rowi))';
        if (aa==1)
            outStr = [outStr '	' mat2str_wenyuan(wi)];
            outStrCnt = [outStrCnt '	' num2str(length(wi))];
        else
            outStr = [outStr '	' mat2str_wenyuan(wi)];
            outStrCnt = [outStrCnt ',' num2str(length(wi))];
        end
    end
    for aa=1:nbY,
        rowi = Yin(aa,1):Yin(aa,2);
        qi = find(Qb(rowi))';
        if (aa==1)
            outStr = [outStr '	' mat2str_wenyuan(qi)];
            outStrCnt = [outStrCnt '	' num2str(length(qi))];
        else
            outStr = [outStr '	' mat2str_wenyuan(qi)];
            outStrCnt = [outStrCnt ',' num2str(length(qi))];
        end
    end
    outStr = [outStrCnt '	' outStr];
    fid=fopen(outFile,'a');
    fprintf(fid,'%s\n',outStr);
    fclose(fid);
end

%%
%%%%%%%%%%%%%  Functions Here %%%%%%%%%%%%%%%%%%%%%%%
function result = NaNerrorCheck(var, msg)
if (~isempty(find(isnan(var)))),
    display(['NaNerrorCheck Warning: ' msg ' NaN found. Exit']);
	result=1;
else
    result=0;
end

function [f]=normaliz(F)
%USAGE: [f]=normaliz(F);
% normalize send back a matrix normalized by column
% (i.e., each column vector has a norm of 1)
[ni,nj]=size(F);
% if (sqrt(sum(F.^2))==0),
%     error('normaliz error: denominator is ZERO!');
% end
v=ones(1,nj) ./ sqrt(sum(F.^2));
f=F*diag(v);

function [sw] =  halfthresholding(w,thrd,msg)
global ZERO
num_nonzeros=length(find(abs(w)>ZERO));
if (num_nonzeros==0)
    display(['halfthresholding Warning: ' msg ' are zeros before half thresholding!']);
    sw=w; return;
elseif (num_nonzeros==1)
    sw=w; return;
end
if (thrd>num_nonzeros), thrd=num_nonzeros-1; end
a=sort(abs(w),'descend');
lambda=a(thrd+1);
%%%%%%%%%%%%%%%%
% it is better to filter those low absolute values of after-selected
% non-zeros!!!
THRD=0.5; % a constant
[me,sd] = meanstd(a(1:(thrd+1)));
lambda1 = me-THRD*sd;
if (lambda1<0), lambda1=me; end
lambda = max(lambda1,lambda); % adjusted lambda
%%%%%%%%%%%%%%%%
ind = logical(abs(w)<lambda);
sw=w;
sw(ind) = 0;

% soft thresholding by using the degree of sparsity
function [sw] =  thresholding(w,thrd,msg)
global ZERO
num_nonzeros=length(find(abs(w)>ZERO));
if (num_nonzeros==0)
    display(['thresholding Warning: ' msg ' are zeros before thresholding!']);
    sw=w; return;
elseif (num_nonzeros==1)
    sw=w; return;
end
if (thrd>num_nonzeros), thrd=num_nonzeros-1; end
a=sort(abs(w),'descend');
lambda=a(thrd+1);
if (lambda==a(1)) % if all the top-ranking 'thrd' values are the same, assign them to 1.
    ind = logical(abs(w)<lambda);
    sw=ones(size(w));
    sw(ind) = 0;
    return;
else
    %%%%%%%%%%%%%%%%
    % it is better to filter those low absolute values of after-selected
    % non-zeros!!!
    THRD=0.5; % a constant
    [me,sd] = meanstd(a(1:(thrd+1)));
    lambda1 = me-THRD*sd;
    if (lambda1<0),
        lambda1=me;
    end
    lambda = max(lambda1,lambda); % adjusted lambda
    %%%%%%%%%%%%%%%%
    ind = logical(abs(w)<lambda);
    sw = w-sign(w).*lambda;
    sw(ind) = 0;
end

function [me sd] = meanstd(a,dim)
% function to compute the mean and SD together
% ca. 25% faster than calling the two functions separately
if nargin<2
    dim=1;
end
me = mean(a,dim);
sd = sqrt((size(a,dim)/(size(a,dim)-1))*(mean(a.^2,dim) - me.^2));

function str=mat2str_wenyuan(mat)
[m,n]=size(mat);
if (m==1 && n==1),
    str=['[' mat2str(mat) ']'];
else
    str=mat2str(mat);
end