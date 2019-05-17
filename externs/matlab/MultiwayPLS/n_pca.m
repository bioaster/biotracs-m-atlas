function [T,Wj,Wk,Wl]=n_pca(X,lv,order,J,K,L);

%
%	Copyright
%	Rasmus Bro 1995
%	Royal Veterinary & Agricultural University, Cph.
%	Thorvaldsensvej 40, 6, ii
%	DK-1871 Frb, C
%	Denmark
%	
%	Phone +45 35283267
%	Fax   +45 35283265
%	E-mail Rasmus.bro@foodsci.kvl.dk
%
%
% Two-way PCA   
% [T,Wj]=n_pca(X,lv,2);
% X is an I x J matrix
%
% Three-way PCA
% [T,Wj,Wk]=n_pca(X,lv,3,J,K);
% X is an I x J x K kube, given as an I x JK matrix
%
% Four-way PCA
% [T,Wj,Wk,Wl]=n_pca(X,lv,4,J,K,L);
% X is a I x J x K x L cube, given as an I x JKL matrix
%
%
% Two-way PCA taken from BMW Toolbox

[I,nx]=size(X);
crit=1e-8;  			% criteria for convergence


%------------------TWO-WAY PCA

if order==2
if nx < I
  cov = (X'*X)/(I-1);
  [u,s,v] = svd(cov);
  Wj = v(:,1:lv);
else
  cov = (X*X')/(I-1);
  [u,s,v] = svd(cov);
  v = X'*v;
  for i = 1:lv
    v(:,i) = v(:,i)/norm(v(:,i));
  end
  Wj = v(:,1:lv);
end
T = X*Wj;
end %if order==2


%------------------THREE-WAY PCA
if order==3

Xres=X;xmodel=zeros(I,J*K);xmod=zeros(I,J*K);T=zeros(I,lv);Wk=zeros(K,lv);Wj=zeros(J,lv);[I,M]=size(X);
maxit=150;

for f=1:lv					% #2

% Initialisation
Xres=Xres-xmodel;[t,wk] = n_pca(Xres,1,2);t=t/norm(t);it=0;tgl=t*2;
wj=ones(J,1); wk=ones(K,1); wjgl=zeros(J,1); wkgl=zeros(K,1);

% Criteria for convergence
while (norm(t-tgl)/norm(t))>crit		% #1

it=it+1;if it==maxit,break,end  
tgl=t; wjgl=wj; wkgl=wk;

% find wj and wk from t
	kov=reshape((Xres'*t),J,K);
	[wj,wk] = n_pca(kov,1,2);
	wj=wj/norm(wj);wk=wk/norm(wk);tgl=t/norm(t);

% find t and wk from wj
	kov=zeros(I,K);for i=1:I,for k=1:K,kov(i,k)=Xres(i,[J*(k-1)+1:J*k])*wj;end,end
	[t,wk] = n_pca(kov,1,2);
	t=t/norm(t);wk=wk/norm(wk);

% find t and wj from wk
	kov=zeros(J,I);for i=1:I,for j=1:J,kov(j,i)=(Xres(i,[j:J:J*K])*wk);end,end
	[wj,t] = n_pca(kov,1,2);
	s(f)=norm(wj);t=t/norm(t);wj=wj/norm(wj);end	 	% #1

Wk(:,f)=wk;Wj(:,f)=wj;T(:,f)=t*s(f);
load=kron(wk,wj)';
xmodel=T(:,f)*load;xmod=xmod+xmodel;end;						% #2
end % if order==3


%------------------FOUR-WAY PCA

if order==4
Xres=X;xmodel=zeros(I,J*K*L);xmod=zeros(I,J*K*L);T=zeros(I,lv);Wj=zeros(J,lv);Wk=zeros(K,lv);Wl=zeros(L,lv);[I,M]=size(X);
maxit=150;

for f=1:lv					% #2

% Initialisation
Xres=Xres-xmodel;[t,wk] = n_pca(Xres,1,2);t=t/norm(t);it=0;tgl=t*2;
wj=ones(J,1); wk=ones(K,1); wl=ones(L,1);  wjgl=zeros(J,1); wkgl=zeros(K,1); wlgl=zeros(L,1);


while (norm(t-tgl)/norm(t))>crit		% #1

it=it+1;if it==maxit,break,end
tgl=t; wjgl=wj;wkgl=wk;wlgl=wl;

% find wj and wk and wl from t
	kov=reshape((Xres'*t),J,K*L);
	[wj,wk,wl]=n_pca(kov,1,3,K,L);
	wj=wj/norm(wj);

% find t and wk and wl from wj
	kov=zeros(I,K*L);for i=1:I,for k=1:K*L,kov(i,k)=Xres(i,[J*(k-1)+1:J*k])*wj;end,end
	[t,wk,wl]=n_pca(kov,1,3,K,L);
	t=t/norm(t);

% find t and wj and wk from wl
	kov=zeros(I,J*K);for i=1:I,klkl=reshape(Xres(i,:)',J*K,L)';kov(i,:)=(klkl'*wl)';end
	[t,wj,wk]=n_pca(kov,1,3,J,K);
	s(f)=norm(t);t=t/norm(t);end	 		% #1

Wl(:,f)=wl;Wk(:,f)=wk;Wj(:,f)=wj;T(:,f)=t*s(f);
load=kron(wl,kron(wk,wj))';
xmodel=T(:,f)*load;xmod=xmod+xmodel;end;						% #2
end % if order ==4
