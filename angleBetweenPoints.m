% Author: Fergal Walsh NUIM 

function theta = angleBetweenPoints(x1,y1,x2,y2,x3,y3)
    H = sqrt((x1-x2).^2 + (y1-y2).^2);
    O = sqrt((x1-x3).^2 + (y1-y3).^2);
    sinTheta = O/H;
    theta = asin(sinTheta);
    theta = 90 - (theta * 180 / pi);
    if theta == 90
        theta = 0;
    end
    if x3 > x2
        theta = 1 - theta;
    end
end