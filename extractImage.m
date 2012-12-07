% Author: Fergal Walsh NUIM 

function I = extractImage(mask, image)
mask = uint8(mask);
mask(mask == 0) = 255;
mask(mask == 1) = 0;
I = image + mask;
end