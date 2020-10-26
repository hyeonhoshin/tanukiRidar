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
U = wdenoise(U_o,2, ...
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

D_merged = three_pts_merge_for_rndsc([X,Y]);
U = realsqrt(D_merged(:,1).^2+D_merged(:,2).^2);
T = atan2(D_merged(:,2),D_merged(:,1));

% U = realsqrt(X.^2+Y.^2);
% T = atan2(Y,X);

%% Ransac fitting

% ------ Parameters ------
sampleSize = 2; % number of points to sample per trial
maxDistance = 1; % max allowable distance for inliers
thres_err_rate = 0.2;
% -------------------------

fitLineFcn = @(points) polyfit(points(:,1),points(:,2),1); % fit function using polyfit
evalLineFcn = ...   % distance evaluation function
  @(model, points) sum((points(:, 2) - polyval(model, points(:,1))).^2,2);

model = [];
pts = [];

u = U(1,:); t = T(1,:);
xs = u.*cos(t); ys = u.*sin(t);

que = [];
for i = 2:length(U)-1
    u = U(i,:); t = T(i,:);
    xs = u.*cos(t); ys = u.*sin(t);
    que = [que; xs ys];
    shape = size(que);
    
    if u < 1
        que(end,:)=[];
        continue
    elseif shape(1) < 5
        continue
    else
        [modelRANSAC, inlierIdx] = ransac([que(:,1),que(:,2)],fitLineFcn,evalLineFcn, ...
      sampleSize,maxDistance);
  
        err_rate = 1 - sum(inlierIdx)/length(inlierIdx);
  
        if err_rate >= thres_err_rate
            bound = shape(1);
            while inlierIdx(bound) == 0
                bound = bound - 1;
            end

            batch = que(1:bound,:);
            que(1:bound,:) = [];
            batch_shape = size(batch);

            ind1 = 0; ind2 =0; flag = false;
            for j = 1: batch_shape(1)
                if inlierIdx(j) == 1 && flag == false
                    ind1 = j;
                    flag = true;
                end
                if flag == true
                    ind2 = j;
                end
            end
            
            x2 = batch(ind1,1); y2 = batch(ind1,2);
            m = modelRANSAC(1); b = modelRANSAC(2);
            b1 = [(x2 - b*m + m*y2)/(m^2 + 1); (y2*m^2 + x2*m + b)/(m^2 + 1)];

            x2 = batch(ind2,1); y2 = batch(ind2,2);
            b2 = [(x2 - b*m + m*y2)/(m^2 + 1); (y2*m^2 + x2*m + b)/(m^2 + 1)];

            pts = [pts; b1.';b2.'];
        end
        
    end
end


pts_u = realsqrt(pts(:,1).^2+pts(:,2).^2);
pts_a = atan2(pts(:,2),pts(:,1));

[pts_a, pts_ind] = sort(pts_a,1);
pts_u = pts_u(pts_ind);
pts_u = [pts_u(pts_a>=0);pts_u(pts_a<0)];
pts_a = [pts_a(pts_a>=0);pts_a(pts_a<0)];

% Plotting and saving

D_merged =[pts_u.*cos(pts_a),pts_u.*sin(pts_a)];

xs = U_o.*cos(T_o); ys = U_o.*sin(T_o); % Only means.
figure(2);
plot(xs,ys,'.','Color','b');
hold on
plot(D_merged(:,1),D_merged(:,2),'o','Color','g');

for i = 1:length(D_merged)-1
    if ~is_inline(D_merged(i,:),D_merged(i+1,:))  %Condition : If is it on p-direction
        % P-direction lines removal  
        plot(D_merged(i:i+1,1),D_merged(i:i+1,2),'-','Color','r','LineWidth',2);
    end
end
legend('Mean from Lidar','Intersected points','Merged lines');
daspect([1 1 1]);
hold off;
title("Output:Extracted Files");
saveas(gcf,'second_merged.png');

disp('...Complete. Final figure is drawn in second_merged.png');
disp('As you want, you can see the preprocessed effects in first_denoised.png')