function [buf_r, buf_a] = merge_lines(dist,angle,thres)

    if nargin <=2
        thres = 0.99
    end

    buf_a = [];
    buf_r = [];
    prior = 1;
    base = 0;
    for i = 1:length(angle)-1
        
%         if abs(dist(i+1)-dist(i)) <= 5
%             similarity = similarity + 0.01;
%         elseif abs(dist(i+1)-dist(i)) <= 10
%             similarity = similarity + 0.005;
%         end

        base = mean(angle(prior:i));
        similarity = (cos(angle(i+1)-base)+1)/2; %Sinusoidal similarity
        
        if thres<=similarity %&& similarity<=1
            continue
        else
            buf_a = [buf_a mean(angle(i))];
            buf_r = [buf_r mean(dist(i))];
            prior = i+1;
        end
    end
end