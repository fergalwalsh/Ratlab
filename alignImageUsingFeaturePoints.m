% Author: Fergal Walsh NUIM 

function I = alignImageUsingFeaturePoints(I)
	theta = 2; % set to anything > 1 to start with
	while abs(theta) > 1
		[x1, y1] = findVentriclePoint(I);% ventricle point
		[x2, y2] = findVPoint(I);% V point
		x3 = x1;
		y3 = y2;
		theta = angleBetweenPoints(x1,y1,x2,y2,x3,y3);	
		I(I==0) = 1;
		I(y2,x2) = 0; % make V point a unique value so we can find it again after rotation
		I(y2,x2+1) = 0;

		I = 255 - I;
		I = imrotate(I,theta,'nearest','crop'); % rotate image
		I = 255 - I;

		[X,Y] = find(I==0,1);% V point
		x2 = Y(1);
		y2 = X(1);
		box = getBoundingBox(I);
		shiftY = 300 - floor(box(2) + (box(4) / 2));
		box(2) = box(2) + shiftY;
		shiftX = 450 - x2;
		I = 255 - I;
		I = circshift(I, [shiftY, shiftX]); % shift image
		I = 255 - I;
	end
end