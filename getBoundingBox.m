% Author: Fergal Walsh NUIM 

function rect = getBoundingBox(I)
B = autoGray2BW(I);
M = createMask(B);
[X, Y] = find(M==1);
x = min(Y);
y = min(X);
w = max(Y) - x;
h = max(X) - y;
rect = [x,y,w,h];
end