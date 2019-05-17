% MULTI-LINEAR PLS (Submitted to J. Chemom.)
% Can handle tri, quadri- and penti-linear X
% and uni-, bi- and tri-linear Y
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
% X is I x J x K  (x L x M) cube and is given as the I x JK (LM) matrix
% y is a I x Jy x Ky cube. Latter indexes run slowest
%
% X and y are assumed centered in this implementation of the algorithm
%
% If a variable 'opt' exists, the algorithm will skip the input part and use
% already defined values of:
%
% Rx	Order of X
% Ry	Order of y
% J..M  Dimension of second .... fifth order of X
% Jy,Jk Dimension of second & third order of y
% lv	Number of latent variables
%
% Outputs:
% T	I x F matrix of scores of X ("loadings" of first order)
% Wj 	J x F loadings in second order of X
% Wk 	K x F loadings in third order of X
% Wl 	L x F loadings in fourth order of X
% Wm 	M x F loadings in fifth order of X
% U 	I x F matrix of scores of y
% Qj 	Jy x F loadings in second order of y
% Qk 	Ky x F loadings in third order of y
% B  	F x F matrix of regression coefficients
% ypred Predictions of calibration set
%
%
% uses N_PCA

if exist('opt') 
disp(' ')
else
lv=input(' How many latent variables should be calculated (default 3!) ');if isempty(lv),lv=3;end;
Rx=input(' What is the order of X (default 3) ');if isempty(Rx),Rx=3;end;
if Rx==2
disp(' ')
disp(' Well, a tri-linear model will be made, but with on variable in the third order')
disp(' The only difference between ordinary and this bi-PLS is that no P loadings are')
disp(' introduced ')
disp(' ')
disp(' Hit any key to continue'),disp(' '),pause,end
Ry=input(' What is the order of Y (default 2 or 1) ');if isempty(Ry),Ry=2;end;

Xidx=['I';'J';'K';'L';'M';'N'];
Yidx=['Iy';'Jy';'Ky'];

[I,Jx]=size(X);[I,Jyy]=size(y);
if Rx==2, J=Jx;K=1;end
if Rx>2
for rx=2:Rx
if exist(Xidx(rx));rrx=eval(Xidx(rx));
if isempty(rrx),rrx=0;end,else,rrx=0;end;
str=([Xidx(rx),'=input('' What is the dimension of the ' , num2str(rx) , ' order of X (default ', num2str(rrx), ') '');']);
eval(str)
if isempty(eval(Xidx(rx))),str=([Xidx(rx),'=rrx;']);eval(str);end;
end,else,J=Jx;
end

if Ry>2
for ry=2:Ry
if exist(Yidx(ry,:));
rrx=eval(Yidx(ry,:));
if isempty(rrx),rrx=0;end
else,rrx=0;end
str=([Yidx(ry,:),'=input('' What is the dimension of the ' , num2str(ry) , ' order of Y  (default ', num2str(rrx), ') '');']);
eval(str)
if isempty(eval(Yidx(ry,:))),str=([Yidx(ry,:),'=rrx;']);eval(str),end;
end
else
Jy=Jyy;
end,clear rrx


end % if isempty(opt)


yres=y;
Xres=X;
ypred=zeros(size(y));
xmodel=zeros(I,Jx);
T=zeros(I,lv);
Wj=zeros(J,lv);
Wk=zeros(K,lv);
if Rx>3,Wl=zeros(L,lv);if Rx>4,Wm=zeros(M,lv);end,end
B=zeros(lv,lv);
Q=zeros(lv,Jyy);
Qj=zeros(Jy,lv);
if Ry>2,Qk=zeros(Ky,lv);end
U=zeros(I,lv);


	sakX=ssq(Xres); saky=ssq(y);
	
	for f=1:lv						% #2
	[u,bbb] = n_pca(yres,1,2);clear bbb
	maxit=250; it=0; ugl=u*2;;

		while (norm(u-ugl)/norm(u))>1e-8		% 		% #3		
		ugl=u;it=it+1;

%______________CALCULATE T

	if Rx<4   % (meaning Rx=3)
	kovxy=reshape((Xres'*u),J,K);
	[wj,wk] = n_pca(kovxy,1,2);
	wj=wj/norm(wj);
	wk=wk/norm(wk);w=reshape(wj*wk',J*K,1)';
	T(:,f)=Xres*w';
	Wj(:,f)=wj;
	Wk(:,f)=wk;
	end

	if Rx==4
	kovxy=reshape((Xres'*u),J,K*L);
	[wj,wk,wl]=n_pca(kovxy,1,3,K,L);
	wj=wj/norm(wj);	wk=wk/norm(wk);wl=wl/norm(wl);
	w=kron(wl,kron(wk,wj))';
	T(:,f)=Xres*w';
	Wj(:,f)=wj;
	Wk(:,f)=wk;
	Wl(:,f)=wl;end

	if Rx==5
	kovxy=reshape((Xres'*u),J,K*L*M);
	[wj,wk,wl,wm]=n_pca(kovxy,1,4,K,L,M);
	wj=wj/norm(wj);	wk=wk/norm(wk); wl=wl/norm(wl); wm=wm/norm(wm);
	w=kron(wm,kron(wl,kron(wk,wj)))';
	T(:,f)=Xres*w';
	Wj(:,f)=wj;
	Wk(:,f)=wk;
	Wl(:,f)=wl;
	Wm(:,f)=wm;
	end


%_______________CALCULATE Q & U

	if Ry<3
	q=T(:,f)'*yres;q=q'/norm(q);Qj(:,f)=q;
	u=yres*q;
	U(:,f)=u;end


	if Ry==3
	q=reshape((yres'*T(:,f)),Jy,Ky);[qj,qk] = n_pca(q,1,2);qj=qj/norm(qj);qk=qk/norm(qk);
	for i=1:I,yi=reshape(yres(i,:),Jy,Ky);
	u(i,1)=(yi*qk)'*qj;end							% #3
	Qj(:,f)=qj;Qk(:,f)=qk;U(:,f)=u;end

end


%_______________CALCULATE B

	B(1:f,f)=inv(T(:,1:f)'*T(:,1:f))*T(:,1:f)'*U(:,f); %y

%_______________CALCULATE PREDICTIONS

	if Ry<3
	ypred=T(:,1:f)*B(1:f,1:f)*Qj(:,1:f)';end
	
	if Ry==3, load=[]; for a=1:Ky load=[load qj'*qk(a)];end;Q(f,:)=load;
	ypred=T(:,1:f)*B(1:f,1:f)*Q(1:f,:);end
	

%________________CALCULATE RESIDUALS

	if Jy > 1,fprintf('number of iterations: %g',it);disp(' '),disp(' '),end
	xmodel=xmodel+T(:,f)*w;
	Xres=X-xmodel;
	yres=y-ypred;
	fprintf('Explained part of X: %g % ',(1-ssq(Xres)/sakX)*100);
	disp(' ')
	fprintf('Explained part of y: %g ',(1-ssq(y-ypred)/saky)*100);
	disp(' ')
	disp(' ')

end					% #2


if it==maxit
('Algoritmen failed')
end
clear w str sakX sakY rx ry maxit kovxy k i k a b c Xidx Yidx f l q u it Jyy ugl wj wk wl wm yres Xres
