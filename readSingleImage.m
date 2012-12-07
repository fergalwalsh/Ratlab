% Author: Fergal Walsh NUIM 

function image = readSingleImage(filename, height, width)
    image = ones(height, width) .* 255;
    I = imread(filename);
    [h,w,d] = size(I);
	if h > height || w > width
	error(['The image "%s" is too large. ' ...
		'\n It is %d x %d. It should be less than %d x %d.'], filename, h, w, height, width);
	end			
    if d > 3
        I = I(:,:,1:3); % discard alpha channel
    end
    I = rgb2gray(I);
	% Pad image so it is centered in frame of size height x width
    t = round((height - h) / 2) + 1;
    b = t + h - 1;
    l = round((width - w) / 2) + 1;
    r = l + w - 1;
    % image(:,:) = I(1,1);
    image(t:b,l:r) = I;
    image = uint8(image);
end