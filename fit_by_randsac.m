% Mid term solutions by randsac
% Init
clc; clearvars;

[file,path,indx] = uigetfile({'*.txt','A text file'});
if indx ~= 1
    disp('Wrong inputs. Try again')
    %exit();
end

D = readmatrix([path,file],'LineEnding','\n');
% Remove Time cols
if D(1) > 10000
    D(:,1) = [];
end
% Remove Error sheet in final cols.
if all(isnan(D(:,end)))
    D(:,end) = [];
end
D = D; % Units to m

deg2rad = pi/180;
step_num = length(D);
angle_range = 240;
sampleSize = 2; % number of points to sample per trial
maxDistance = 1; % max allowable distance for inliers

fitLineFcn = @(points) polyfit(points(:,1),points(:,2),1); % fit function using polyfit
evalLineFcn = ...   % distance evaluation function
  @(model, points) sum((points(:, 2) - polyval(model, points(:,1))).^2,2);

% Calculate params
U = median(D,1).';                                         %682*1
V = var(D,0,1).'; % Calculate by sample variance.           682*1
T = (linspace(0,angle_range,step_num).')*deg2rad;          %682*1

% windowing
window_size = 7;
stride = window_size;
model = [];
for offset = 1:stride:length(U)-window_size
    disp(['Progress.....',num2str(int32(offset*100/(length(U)-window_size))),'%']);
    s = offset; e = window_size+offset;
    u = U(s:e); v = V(s:e); t = T(s:e);
    if all(u ~=0) && all(v ~=0)
        [modelRANSAC, inlierIdx] = ransac([u.*cos(t),u.*sin(t)],fitLineFcn,evalLineFcn, ...
  sampleSize,maxDistance);
        
        model = [model; modelRANSAC];

        %plot_polar_line_range(r,a, u(1)*cos(t(1)), u(end)*cos(t(end)) );
        %plot_polar_pts(u,t);
    else
        disp('0 vectors...pass')
    end
    
    disp('...Complete. Draw a figure in png file');
end

[R,A] = rect2polar(model(:,1),model(:,2));

[buf_r, buf_a] = merge_lines(R,A,0.95);
plot_lines(buf_r, buf_a,U(1)*cos(T(1)),U(1)*sin(T(1)));