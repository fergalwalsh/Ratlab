% Author: Fergal Walsh NUIM 

function [x2, y2] = findPoint2(I)
	B = autoGray2BW(I);
	M = createMask(B);
	% Now find V point
	M = M(1:300, 400:500);
	[x, y] = find(M == 0);
	[v, i] = max(x);
	x2 = y(i) + 400;
	y2 = v;
