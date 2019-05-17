function cv_score=getCVscore(X,Xin,Y,Yin,param,randRowPartitions)
if nargin == 0
   help getCVscore
   return
end

global ZERO
ZERO=eps;
[n,m] = size(X);
nbX = size(Xin,1); % nbX : #blocks in X
[n,p] = size(Y);
nbY = size(Yin,1); % nbY : #blocks in Y
nfold=length(randRowPartitions);
cv_score=0;
 
for k=1:nfold,
%     fprintf('\t %d/%d fold:\n', k, nfold);
    rowi_selected=randRowPartitions{k};
    rowi_rest=union_cells(randRowPartitions,setdiff(1:nfold,k));
    XX_train = X(rowi_rest,:);
    XX_test = X(rowi_selected,:);
    YY_train = Y(rowi_rest,:);
    YY_test = Y(rowi_selected,:);
    [success,oneF.Tb,oneF.Pb,oneF.Wb,oneF.Wt,oneF.Tt,oneF.Ub,oneF.Qb,...
        oneF.QQb,oneF.Wu,oneF.Tu]=sMBbpls_oneFactor(XX_train,Xin,YY_train,Yin,param);
    if (success),
        for aa=1:nbX,
            rowi = Xin(aa,1):Xin(aa,2);
            a=XX_test(:,rowi)*oneF.Wb(rowi)/(oneF.Wb(rowi)'*oneF.Wb(rowi));
            b=XX_test(:,rowi)'*a/(a'*a);
            d=approx_dist(XX_test(:,rowi),a,b); % squared distance between two matrices, XX_test and a*b'
            cv_score=cv_score+d;
        end
        for aa=1:nbY,
            rowi = Yin(aa,1):Yin(aa,2);
            a=YY_test(:,rowi)*oneF.Qb(rowi)/(oneF.Qb(rowi)'*oneF.Qb(rowi));
            b=YY_test(:,rowi)'*a/(a'*a);
            d=approx_dist(YY_test(:,rowi),a,b); % squared distance between two matrices, XX_test and a*b'
            cv_score=cv_score+d;
        end
    end
end

%%
%%%%%%%%%%%%%  Functions Here %%%%%%%%%%%%%%%%%%%%%%%
% X: mxn matrix, u: mx1 vector, v: nx1 vector
function d=approx_dist(X,u,v)
[m,n]=size(X);
d=sum(sum((X-u*v').^2));
d=d/(m*n);
function array=union_cells(cellarray,listi) % suppose array in each cell is a column vector.
n=length(cellarray);
if (max(listi)>n),
    error('union_cells error: max of listi > length of cell array.');
end
array=[];
for i=1:length(listi),
    array=[array; cellarray{listi(i)}];
end

function randpartitions=rand_nFold(n,nfold)
randpartitions=cell(nfold,1);
sizePartition=ceil(n/nfold);
r = randperm(n);
base=1;
for i=1:(nfold-1),
    randpartitions{i,1}=r((base:(base+sizePartition-1)))';
    base = base+sizePartition;
end
randpartitions{nfold,1}=r(base:n)';
