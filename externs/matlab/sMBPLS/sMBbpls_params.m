% params = sMBbpls_params([5;10;15],{[2;3],[4;5],[10;20],[100;200]},[10;15;20],nfactor)
function params = sMBbpls_params(thrXYr_list,thrXc_list,thrYc_list,nfactor)
maxIter=200; epsilon=eps;
combparams=thrXYr_list;
nbX=length(thrXc_list);
for i=1:length(thrXc_list),
    combparams = combinelist(combparams,thrXc_list{i});
end
combparams = combinelist(combparams,thrYc_list);
[nparam,m]=size(combparams);
params.param=cell(nparam,1);
for i=1:nparam,
    params.param{i}=sMBbpls_param(combparams(i,1),combparams(i,2:(nbX+1)),...
        combparams(i,1),combparams(i,m),nfactor,maxIter,epsilon);
end
params.maxIter=maxIter;
params.epsilon=epsilon;
params.combparams=combparams;
params.nfactor=nfactor;

%%
function comblist=combinelist(list1,list2)
[n1,m1]=size(list1);
[n2,m2]=size(list2);
n_comb=n1*n2;
m_comb=m1+m2;
comblist=zeros(n_comb,m_comb);
for i=1:n1,
    comblist(((i-1)*n2+1):(i*n2),1:m1)=repmat(list1(i,:),n2,1);
end
comblist(:,(m1+1):m_comb)=repmat(list2,n1,1);

function param = sMBbpls_param(thrXr,thrXc,thrYr,thrYc,nfactor,maxIter,epsilon)
if (nargin==5),
    maxIter=200; epsilon=eps;
end
param.nfactor = nfactor;
param.thrXr  = thrXr;
param.thrXc = thrXc;
param.thrYr = thrYr;
param.thrYc  = thrYc;
param.maxIter = maxIter;
param.epsilon = epsilon;




