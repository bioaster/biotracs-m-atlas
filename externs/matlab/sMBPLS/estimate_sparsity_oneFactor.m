function [param_idx,cv_scores]=estimate_sparsity_oneFactor(X,Xin,Y,Yin,params)
nparam = length(params.param);
cv_scores = zeros(nparam,1);
randRowPartitions = params.randRowPartitions;
step=ceil(nparam/10);
if (nparam>1)
    for i=1:nparam,
        if (rem(i,step)==0), fprintf('\b\b\b%d%%',floor(i*100/nparam)); end
        cv_scores(i)=getCVscore(X,Xin,Y,Yin,params.param{i},randRowPartitions);
    end
    fprintf('\n');
    [mincv,param_idx]=min(cv_scores);
elseif (nparam==1)
    param_idx=1;
end

