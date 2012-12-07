% Author: Fergal Walsh NUIM 

function I = alignImageUsingMoments(I)
	B = autoGray2BW(I);
	B = createMask(B);
	[x, y] = bin_position(B,1);
	[rho, theta] = bin_axis(B,1);
	thetaDeg = (theta * 180 / pi);%convert theta from radians to degrees
	thetaDeg = thetaDeg - 90;
	theta = thetaDeg;
	shiftY = 300 - round(y);
	shiftX = 450 - round(x);

	I = 255 - I;
	I = imrotate(I,theta,'nearest','crop');
	I = circshift(I, [shiftY, shiftX]);
	I = 255 - I;
end