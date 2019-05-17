function [mcx,mx] = mncn(x)
%  mean centers matrix x and returns a vector of means (mx)
%  used in the scaling.  I/O format is:
%  [mcx,mx] = mncn(x);

%  Copyright
%  Barry M. Wise
%  1991

[m,n] = size(x);
mx = mean(x);
mcx = zeros(m,n);
for i = 1:m
  mcx(i,:) = (x(i,:) - mx);
end
