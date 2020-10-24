function [Y] = three_pts_merge(X)
%      Input : x = [x1;
%                   x2;
%                   x3;]
%      Output : y = [y1; y2] or [y1;y2;y3]

%       x1 ----- x2 ----- x3 인 경우, x1~x3와 x1~x2+x2~x3는 거의 같음.

    if dist2(X(1,:),X(3,:)) == dist2(X(1,:),X(2,:))+dist2(X(2,:),X(3,:))
        X(2,:) = [];
    end
    
    Y = X;
end

function [d] = dist2(v1,v2)
    d = sqrt(v1.'*v1-2*v1.'*v2+v2.'*v2);
end