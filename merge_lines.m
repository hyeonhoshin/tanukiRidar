function [buf_r, buf_a] = merge_lines(dist,angle)
    buf_a = [];
    buf_r = [];
    prior = 1;
    for i = 1:length(angle)-1
        
        similarity = (cos(angle(i+1)-angle(i))+1)/2; %Sinusoidal similarity
%         if abs(dist(i+1)-dist(i)) <= 5
%             similarity = similarity + 0.01;
%         elseif abs(dist(i+1)-dist(i)) <= 10
%             similarity = similarity + 0.005;
%         end
        
        if 0.99<=similarity %&& similarity<=2
            continue
        else
            buf_a = [buf_a mean(angle(prior:i))];
            buf_r = [buf_r mean(dist(prior:i))];
            prior = i+1;
        end
    end
end