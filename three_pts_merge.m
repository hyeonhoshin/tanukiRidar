function [Q] = three_pts_merge(X)
    Q = X(1:3,:);
    for next = 4:length(X)
        buf = Q(end-2:end,:);
        Q(end-2:end,:) = [];
        
        Y = merge_in_batch(buf);
        Q = [Q;Y];
        Q = [Q;X(next,:)];
    end
end

function [Y] = merge_in_batch(X)
%      Input : x = [x1;
%                   x2;
%                   x3;]
%      Output : y = [y1; y2] or [y1;y2;y3]

%       x1 ----- x2 ----- x3 인 경우, x1~x3와 x1~x2+x2~x3는 거의 같음.
    d13 = dist2(X(1,:),X(3,:));
    d12 = dist2(X(1,:),X(2,:)); d23 = dist2(X(2,:),X(3,:));
    
    diff = d13/(d12+d23);

    if (1/1.0015 <= diff && diff <=1.0015) || (diff >=5) || (diff <=1/5)
        X(2,:) = [];
    end  
    Y = X;
end

function [d] = dist2(v1,v2)
    d = realsqrt(v1*(v1.')-2*v1*(v2.')+v2*(v2.'));
end