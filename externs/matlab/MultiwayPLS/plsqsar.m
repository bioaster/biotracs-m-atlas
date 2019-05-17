function [Xnew,dim,idx]=plsqsar(X,y,Rx,J,K,L,M);

%
% [Xnew,dim,idx]=plsqsar(X,y,Rx,J,K,L,M);
%
% Takes the multiway X and y as inputs, make a model for interpretation
% and gives the opportunity to make a sub-cube, Xnew, for furter investigation.
% Also the original variables are given in idx. Xnew=X(:,idx);
% dim contains the dimensions of the new sub-array
%
% X  is a I x J (x K x L x M) array given as the unfolded I x JKLM matrix
% y  is an I (x J) matrix
% Rx is the order of X (between 2 and 5)
% J  is the dimension of the second order
%
% Only give the below if X is of the corresponding order
% K  is the (optional) dimension of the third order
% L  is the (optional) dimension of the fourth order
% M  is the (optional) dimension of the fifth order
%
% Copyright May 1995
% Rasmus Bro
% Royal Vet. & Agri. University, Thorvaldsensvej 40
% DK-1871 Frb. C, Denmark
% e-mail Rasmus.Bro@pop.foodsci.kvl.dk


%_____INITIALISATION

opt=1;
loadname=[' T';'Wj';'Wk';'Wl';'Wm'];
[I,Jy]=size(y);Ry=2;
[I,Jx]=size(X);
if nargin==4,Rx=3;K=1;end % bi-PLS using tri-PLS
if nargin==5,Rx=3;end  % tri-PLS
if nargin==6,Rx=4;end  % quadri-PLS
if nargin==7,Rx=5;end  % penti-PLS


%_____DEFINE WHICH Y-COLUMN

if Jy>1
var=input(' Do you wish to use one (1) or all columns of y (0) :');
if isempty(var),var=0;end;end
if var==1
Jy=1;
var=input(' Which column of y should be used: ');
if isempty(var),var=1;end;y=y(:,var);end
end
end

%_____DO INITIAL PLS

lv=input(' How many latent variables should be used (1 default): ');
if isempty(lv),lv=1;end
n_pls;


%_____MAKE PLOTS FOR INTERPRETATION

for num=1:Rx
figure(num);eval(['plot(',loadname(num,:),'(:,1))']);
eval(['title('' Loading in ',num2str(num),' order '')']);drawnow;
for i=1:20000,10*10;end  % to make a short break
end

%_____DEFINE WHICH VARIABLES TO SELECT (first order in var1 ...)

dim=[I];
for num=2:Rx
 a=[];
 c=1;
 while c >0
  eval(['c=input('' Include variable # in the ', num2str(num) ,' order: 0 (stop) '');if isempty(c),c=0;end'])
  if c>0;a=[a c];end
 end %while
 dim=[dim max(size(a))];
 eval(['var',num2str(num),'=a;'])
 eval(['var',num2str(num)'])
end % for num=1

%______MAKE REDUCED ARRAY USING VAR...

disp(' Making sub-array, wait a minute')
idxx=0;
idx=[];

if Rx==3;
for k=1:K
for j=1:J
idxx=idxx+1;
if (min(abs(var2-j))==0 & min(abs(var3-k))==0),idx=[idx idxx];end
end,end
end % if Rx=3

if Rx==4;
for l=1:L
for k=1:K
for j=1:J
idxx=idxx+1;
if (min(abs(var2-j))==0 & min(abs(var3-k))==0 & min(abs(var4-l))==0),idx=[idx idxx];end
end,end,end
end % if Rx=4

if Rx==5;
for m=1:M
for l=1:L
for k=1:K
for j=1:J
idxx=idxx+1;
if (min(abs(var2-j))==0 & min(abs(var3-k))==0 & min(abs(var4-l))==0 & min(abs(var5-m))==0),idx=[idx idxx];end
end,end,end,end
end % if Rx=4

%______MAKE SUB-ARRAY

Xnew=X(:,idx);