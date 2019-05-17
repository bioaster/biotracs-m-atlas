function [mcx,mx,sx,mcy,my,sy]=scal(X,y,scameth);

[I,J]=size(X);
[I,M]=size(y);

if scameth==1
mcx=X;mx=zeros(1,J);sx=1;
mcy=y;my=zeros(1,M);sy=1;
end

if scameth==2

[mcx,mx]=mncn(X);sx=1;
[mcy,my]=mncn(y);sy=1;
end

if scameth==3
[mcx,mx,sx]=auto(X);
[mcy,my,sy]=auto(y);
end
