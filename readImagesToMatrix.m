% Author: Fergal Walsh NUIM 

function images = readImagesToMatrix(filenames, height, width)
    numImages = length(filenames);
    images = ones(height, width, numImages) .* 255;
    for i=1:numImages
        I = imread(filenames{i});
        [h,w,d] = size(I);
		if h > height || w > width
		error(['The image "%s" is too large. ' ...
			'\n It is %d x %d. It should be less than %d x %d.'], filenames{i}, h, w, height, width);
		end			
        if d > 3
            I = I(:,:,1:3); % discard alpha channel
        end
        if d > 1
            I = rgb2gray(I);
        end
		% Pad image so it is centered in frame of size height x width
        t = round((height - h) / 2) + 1;
        b = t + h - 1;
        l = round((width - w) / 2) + 1;
        r = l + w - 1;
        images(:,:,i) = I(1,1);
        images(t:b,l:r,i) = I;
    end
    images = uint8(images);
end