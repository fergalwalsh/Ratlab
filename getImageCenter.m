% Author: Fergal Walsh NUIM 
% Finds the center point of a binary image. 
function [cx, cy] = getImageCenter(image)
    [x , y] = find(image);
    cx = floor((max(x) + min(x)) / 2);
    cy = floor((max(y) + min(y)) / 2);
end