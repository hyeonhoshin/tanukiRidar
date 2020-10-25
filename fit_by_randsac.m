% Mid term solutions by randsac
%% Data Reading by UI
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

% Initial parameters
deg2rad = pi/180;
step_num = length(D);
angle_range = 240;

%% Rough Filtering by Maximum Likelihood 
U_o = median(D,1).';                                         %682*1
T_o = (linspace(0,angle_range,step_num).')*deg2rad;          %682*1

%% Wavelet Denoising
U = wdenoise(U_o,4, ...
    'Wavelet', 'sym4', ...
    'DenoisingMethod', 'Bayes', ...
    'ThresholdRule', 'Median', ...
    'NoiseEstimate', 'LevelIndependent');

% Plotting and saving
xs = U_o.*cos(T_o); ys = U_o.*sin(T_o); % Tranform to Cartesian cord
plot(xs(1:20),ys(1:20),'x-');
hold on;

X = U.*cos(T_o); Y = U.*sin(T_o); % Tranform to Cartesian cord
plot(X(1:20),Y(1:20),'.-');
daspect([1 1 1]);
legend('Mean of original', 'Wavelet filtered');
title('After filtering');
hold off;
saveas(gcf,'first_denoised.png');

D_merged = three_pts_merge([X,Y]);
U = realsqrt(D_merged(:,1).^2+D_merged(:,2).^2);
T_o = atan2(D_merged(:,2),D_merged(:,1));

%% Ransac fitting

% ------ Parameters ------
sampleSize = 2; % number of points to sample per trial
maxDistance = 1; % max allowable distance for inliers
thres_angle_diff = 0.998;
% -------------------------

fitLineFcn = @(points) polyfit(points(:,1),points(:,2),1); % fit function using polyfit
evalLineFcn = ...   % distance evaluation function
  @(model, points) sum((points(:, 2) - polyval(model, points(:,1))).^2,2);

% windowing
window_size = 8;
stride = window_size/2;
model = [];
pts = [];
for offset = 1:stride:length(U)-window_size
    disp(['Progress.....',num2str(int32(offset*100/(length(U)-window_size))),'%']);
    s = offset; e = window_size+offset;
    u = U(s:e); t = T_o(s:e);
    if all(u ~=0)
        [modelRANSAC, inlierIdx] = ransac([u.*cos(t),u.*sin(t)],fitLineFcn,evalLineFcn, ...
  sampleSize,maxDistance);  
        model = [model; modelRANSAC];
        dir = [1; modelRANSAC(1)];
        
        ind1 = 0; ind2 =0; flag = false;
        for i = 1: length(inlierIdx)
            if inlierIdx(i) == 1 && flag == false
                ind1 = i;
                flag = true;
            end
            if flag == true
                ind2 = i;
            end
        end
        
        x2 = u(ind1).*cos(t(ind1)); y2 = u(ind1).*sin(t(ind1));
        m = modelRANSAC(1); b = modelRANSAC(2);
        b1 = [(x2 - b*m + m*y2)/(m^2 + 1); (y2*m^2 + x2*m + b)/(m^2 + 1)];
        
        x2 = u(ind2).*cos(t(ind2)); y2 = u(ind2).*sin(t(ind2));
        b2 = [(x2 - b*m + m*y2)/(m^2 + 1); (y2*m^2 + x2*m + b)/(m^2 + 1)];
        
        pts = [pts; b1.';b2.'];
    else
        disp('0 vectors...pass')
    end
    
    disp('...Complete. Draw a figure in png file');
end


pts_u = realsqrt(pts(:,1).^2+pts(:,2).^2);
pts_a = atan2(pts(:,2),pts(:,1));

[pts_a, pts_ind] = sort(pts_a,1);
pts_u = pts_u(pts_ind);
pts_u = [pts_u(pts_a>=0);pts_u(pts_a<0)];
pts_a = [pts_a(pts_a>=0);pts_a(pts_a<0)];

plot(pts_u.*cos(pts_a),pts_u.*sin(pts_a),'x-');

[R,A] = rect2polar(model(:,1),model(:,2));
figure(2);

plot_lines(R, A,U(1)*cos(T_o(1)),U(1)*sin(T_o(1)));
hold on;
title("Output:Extracted Files");
saveas(gcf,'second_merged.png');

% % Plotting and saving
% plot(xs,ys,'.','Color','b');
% hold on
% plot(D_merged(:,1),D_merged(:,2),'o','Color','g');
% plot(D_merged(:,1),D_merged(:,2),'-','Color','r','LineWidth',2);
% legend('Mean from Lidar','Intersected points','Merged lines');
% title('After filtering');
% daspect([1 1 1]);
% hold off;
% 
% saveas(gcf,'second_merged.png');
% 
% disp('...Complete. Final figure is drawn in second_merged.png');
% disp('As you want, you can see the preprocessed effects in first_denoised.png')