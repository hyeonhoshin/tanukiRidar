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
U_o = mean(D,1).';                                           %682*1
T_o = (linspace(0,angle_range,step_num).')*deg2rad;          %682*1

%% Wavelet Denoising
U = wdenoise(U_o,3, ...
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

%% Three points merging

D_merged = three_pts_merge([X,Y]);

T = atan2(D_merged(:,2),D_merged(:,1));
U = sqrt(D_merged(:,2).^2 + D_merged(:,1).^2);% Tranform to Polar cord

% Plotting and saving
plot(D_merged(:,1),D_merged(:,2),'o');
hold on
plot(D_merged(:,1),D_merged(:,2),'-');
legend('Merged points','Intersected points');
title('After filtering');
daspect([1 1 1]);
hold off;
title("
saveas(gcf,'second_merged.png');

disp('...Complete. Final figure is drawn in second_merged.png');
disp('As you want, you can see the preprocessed effects in first_denoised.png')