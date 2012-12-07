% Author: John Mc Donald

function [x,y] = bin_position(l,label)

A = bin_area(l,label);

[yp,xp] = find (l == label);
x = sum(xp)/A;
y = sum(yp)/A;



