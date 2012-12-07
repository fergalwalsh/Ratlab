function [x1, y1] = findPoint1(I)
I = 1 - autoGray2BW(I);
I = I(:, 400:500);
I = bwmorph(I, 'close', 4);
I = bwmorph(I, 'open', 4);
I = bwmorph(I, 'erode', 2);
I = bwmorph(I, 'dilate', 2);
[L, n] = bwlabel(I);
a = L(2,2); % Label of area above brain
b = L(end-1,2); % Label of area below brain
c = 0; % Label of the brain area
y1 = 0;
x1 = 0;
for i=1:n
    if(i~=a && i~=b && i~=c)
        [x,y] = bin_position(L,i);
        if y > y1
            y1 = round(y);
            x1 = 400 + round(x);
        end
    end
end