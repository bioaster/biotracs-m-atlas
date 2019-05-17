function [mtx,mty]=rescal(X,y,scameth,mx,sx,my,sy);


if scameth==1
mtx=X;
mty=y
end

if scameth==2

mtx=scale(X,mx);
mty=scale(y,my);
end

if scameth==3
mtx=scale(X,mx,sx);
mty=scale(y,my,sy);
end
