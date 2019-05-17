function [Zm,mz] = meanc(Z,mz,rev)
% function [Zm,mz] = meanc(Z)
% function [Zm] = meanc(Z,mz)
% function [Zm] = meanc(Z,mz,1)
% 010510
% 
% in: Z (objects x variables) data block
%     mz (1 x variables) column means
%     rev (1 x 1) trigger to reverses mean centering operation 
%
% out:Zm (objects x variables) mean centred data block, or if 
%     input 'rev' is activated, reverses data block centering
%     mz (1 x variables) column means

if (nargin == 0)
   help meanc
   return
end   

[n,m] = size(Z);
if nargin == 1
   if ~sum(sum(isnan(Z)))
      mz = mean(Z);
      Zm = Z-mz(ones(n,1),:);
   else
      Zmv = sparse(isnan(Z));
      zmv = n./(n-sum(Zmv));
      Z(Zmv) = 0;
      mz = mean(Z).*zmv;
      Zm = Z-mz(ones(n,1),:);
      Zm(Zmv) = NaN;
   end
elseif nargin == 2
   Zm = Z-mz(ones(n,1),:);
elseif nargin == 3
   Zm = Z+mz(ones(n,1),:);
end
