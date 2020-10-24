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

% Calculate params
U_o = median(D,1).';                                         %682*1
V = var(D,0,1).'; % Calculate by sample variance.           682*1
T_o = (linspace(0,angle_range,step_num).')*deg2rad;          %682*1

% Wavelet Denoising
U = wdenoise(U_o,2, ...
    'Wavelet', 'sym4', ...
    'DenoisingMethod', 'Bayes', ...
    'ThresholdRule', 'Median', ...
    'NoiseEstimate', 'LevelIndependent');

% Merging Only
X = U.*cos(T_o); Y = U.*sin(T_o);
D_merged = three_pts_merge([X,Y]);
T = atan2(D_merged(:,2),D_merged(:,1));
U = sqrt(D_merged(:,2).^2 + D_merged(:,1).^2);

plot(D_merged(:,1),D_merged(:,2),'o');
hold on
plot(D_merged(:,1),D_merged(:,2),'-');
%plot(X,Y,'.');
%plot(U_o.*cos(T_o),U_o.*sin(T_o),'x');

%legend('Merged points','Path of pts','Wavelet filtered','Mean of original');
legend('Merged points','Path of pts');


disp('...Complete. Draw a figure in png file');

% plot_lines(U, T,U(1)*cos(T(1)),U(1)*sin(T(1)));