function [bool] = is_inline(pt1,pt2)
%   The pt1's angle is smaller than pt2.
%   The let pt p3 has more r than pt
%   p1(origin) ------- p2 ------- p3

    p1 = [0,0];
    if pt1*pt1.' > pt2*pt2.'
        p3 = pt1; p2 = pt2;
    else
        p3 = pt2; p2 = pt1;
    end
    
    r13 = norm(p1-p3);
    r12 = norm(p1-p2); r23 = norm(p2-p3);
    
    diff = r13/(r12+r23);
    
    if (1/1.0005 <= diff && diff <=1.0005) || r12<3
        bool = true;
    else
        bool = false;
    end
end