function [r,a] = rect2polar(slope, bias)
% Convert rectangular line data to line in polar cordinates
    a = atan2(-1,slope);
    r = bias.*sin(a);
end