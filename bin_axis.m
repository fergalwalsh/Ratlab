% Author: John Mc Donald

function [rho,theta] = bin_axis(l,label)

[mu_col,mu_row]=bin_position(l,label);

[row,col] = find(l==label);

% r' = r - mu_r;
rowp = row - mu_row;

% c' = c - mu_c;
colp = col - mu_col;

a = colp' * colp;
c = rowp' * rowp;
b = 2 * rowp' * colp;

if (b==0)&((a-c)==0)
   error('Symmetry detected: ambiguous axis of symmetry');
end

theta = 0.5*(atan2(b,(a-c))+pi);
rho = mu_col * cos(theta) + mu_row * sin(theta);
