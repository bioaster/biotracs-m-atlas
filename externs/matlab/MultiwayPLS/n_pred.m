% prediction in N-PLS
% X is a I x J x K (x L x M) array, given as an I x JK (I x JKLM) matrix
% ypred is I x JK
% Remmember to center X and y
%
% lv (# latent variables), Rx (order of X) and Ry (order of y)
% defines what happens 

[I,not]=size(X);clear not
Xres=X;

t=zeros(I,lv);
[wk1, wk2]=size(Wj);
Wjj=Wj(:,1:lv);
Wkk=Wk(:,1:lv);
if Rx>3
Wll=Wl(:,1:lv);
if Rx>4
Wmm=Wm(:,1:lv);end,end

Qjj=Qj(:,1:lv);
if Ry>2
Qkk=Qk(:,1:lv);end

clear wk1 wk2


for f=1:lv

load=kron(Wkk(:,f),Wjj(:,f))';
if Rx>3,load=kron(Wll(:,f),load')';end
if Rx>4,load=kron(Wmm(:,f),load')';end

t(:,f)=Xres*load';
Xres=Xres-t(:,f)*load;
end

for f=1:lv,

if Ry>2
load=[];
for a=1:Ky
load=[load Qjj(:,f)'*Qkk(a,f)];
end;
else
load=Qj(:,f)';
end
Q(f,:)=load;
end
clear load

ypred=t(:,1:lv)*B(1:lv,1:lv)*Q(1:lv,:);

end

clear Qjj Qkk Wjj Wkk Wll Wmm