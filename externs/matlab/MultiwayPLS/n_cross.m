function [ypr,press]=n_cross(Xc,yc);

% [ypr,press]=n_cross(Xc,yc);
% Output: press lv x 1, and ypr (cross-validated predictions)

[II,JJ]=size(Xc);

ypr=zeros(size(yc));

lvv=input(' Maximum number of lv ');

%----------------PREPROCESSING-----------------------------
str1='No preprocessing';str2='Meancentered';str3='Autoscaled';
scameth=menu(' What method of preprocessing should be used ', str1,str2,str3);


%----------------METHOD-------------------------------------
str1='Full';str2='Subset';str3='Bootstrap';str4='Test';
method=menu(' Next question, how would you like it to be done ',str1,str2,str3,str4);
if method==4
disp('Well, unfortunately not available; will use subset instead'),method=2;end

if method ==2
nset=input(' Number of subsets ');
if nset>II
disp('Wrong number, try again'), keyboard,end
str1='Random';str2='Systematically';
system=menu(' Last question; how should these set be chosen' , str1,str2);
if system==2
str1='123...123';str2='111...222';
seq=menu(' Sorry, one more ',str1,str2);
end % if system
end % if method



%____________________FULL CROSS VALDIATION__________

if method==1
 press=zeros(lvv,1);
  for ii=1:II
  if ii>1, opt=3;end
  [mcx,mx,sx,mcy,my,sy]=scal(delsamps(Xc,ii),delsamps(yc,ii),scameth);
  [mtx,mty]=rescal(Xc(ii,:),yc(ii,:),scameth,mx,sx,my,sy);
  X=mcx;y=mcy;
  [I,JJ]=size(y);
  n_pls;
   for lv=1:lvv
   X=mtx;y=mty;
   n_pred;
   press(lv)=press(lv)+ssq(ypred-mty);
   if lv==lvv,ypr(ii,:)=(sy.*ypred)+my;end
   end % for lv
  end % for ii
end % if method

%_____________________SUBSET SYSTEM___111...222__________

if method==2
if system==2
if seq==2
disp('method=2')
press=zeros(lvv,1);
numb=round(II/nset);
for set=1:nset
if set>1, opt=3;end
calix=ones(1,II);
predidx=zeros(1,II);
predidx(set*numb-(numb-1):min(set*numb,II))=ones(size(predidx(set*numb-(numb-1):min(set*numb,II))));
calidx=calix-predidx;
if sum(predidx)==0, break, end
[mcx,mx,sx,mcy,my,sy]=scal(Xc(calidx,:),yc(calidx,:),scameth);
[mtx,mty]=rescal(Xc(predidx,:),yc(predidx,:),scameth,mx,sx,my,sy);
[I,JJ]=size(mcx);
X=mcx;y=mcy;
opt
n_pls
X=mtx;y=mty;
for lv=1:lvv
n_pred
press(lv)=press(lv)+ssq(ypred-mty);
size(sy)
size(ypred)
size(my)
if lv==lvv,[sizy,sizyy]=size(ypred);ypr(predidx,:)=(sy.*ypred)+ones(sizy,1)*my;end
end % for l
end % for set
end % if seq
end % system
end % method
