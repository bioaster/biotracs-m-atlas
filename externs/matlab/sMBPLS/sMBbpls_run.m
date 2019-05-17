function sMBbpls_run(data_file,result_file)
clear global X Xin Y Yin
clear global Tb Pb Wb Wt Tt Ub Qb Wu Tu
global X Xin Y Yin
global Tb Pb Wb Wt Tt Ub Qb Wu Tu
global nfactor params
%%%%%%%%% you may define your own combinations of parameters here %%%%%%%%%
% For each parameter, please use semicolon to separate different values for
% this parameter.
thrXYr_list=[20;30];
thrXc_list={[20;30],[20;30],[20;30]};
thrYc_list=[20;30];
nfactor=1;
params = sMBbpls_params(thrXYr_list,thrXc_list,thrYc_list,nfactor);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(data_file);
X=data.X; Y=data.Y; Xin=data.Xin; Yin=data.Yin;
colormap_types={'blue-white-red','blue-white-red','blue-white-red','blue-white-red'};
sMBbpls_plot_XY(data_file,100,'Original data',colormap_types);
nbX = size(Xin,1);
for aa=1:nbX
   rowi = Xin(aa,1):Xin(aa,2);
   X(:,rowi)=meanc(X(:,rowi));
end
Y=meanc(Y);
[nfactor,Tb,Pb,Wb,Wt,Tt,Ub,Qb,QQb,Wu,Tu,params]=sMBbpls_CV(params,5,[result_file '.txt']);
save([result_file '.mat'],'Tb','Pb','Wb','Wt','Tt','Ub','Qb','QQb','Wu','Tu','params');

sMBbpls_plot_XY(data_file,200,'Reordered data by sMBPLS solution vector',colormap_types,1);
fig1=1; fig2=2;
sMBbpls_plot_results(data_file,1,fig1,fig2,'blue-white-red');

