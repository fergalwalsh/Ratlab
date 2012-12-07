% Author: Fergal Walsh NUIM 

function B = createMask(B)
B = bwmorph(B, 'clean', 1);
B = imfill(B, 'holes');
[L, num] = bwlabel(B);
[h,w] = size(B);
totalArea = h*w;
maxArea = 0;
maxi = 0;
for i=1:num
    a = length(find(L==i));
    if a > maxArea
        maxArea = a;
        maxi = i;
        if a > totalArea / 2
            break;
        end
    end
end
IX = find(L==maxi);
B(:) = 0;
B(IX) = 1;
end