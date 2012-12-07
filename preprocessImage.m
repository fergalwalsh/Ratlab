% Author: Fergal Walsh NUIM 

function I = preprocessImage(I)
I = imadjust(I);
B = autoGray2BW(I);
M = createMask(B);
I = extractImage(M, I);
end
