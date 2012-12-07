% Author: Fergal Walsh NUIM 

function bw = autoGray2BW(I)
level = graythresh(I);
bw = 1 - im2bw(I,level);
end