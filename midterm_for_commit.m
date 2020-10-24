% Mid term solutions
% Init
clc; clearvars;
deg2rad = pi/180;

step_num = 682;
angle_range = 240;

[file,path,indx] = uigetfile({'*.txt','A text file'});
if indx ~= 1
    disp('Wrong inputs. Try again')
    exit();
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

% Calculate params
U = mean(D,1).';                                           %682*1
V = var(D,0,1).'; % Calculate by sample variance.           682*1
T = (linspace(0,angle_range,step_num).')*deg2rad;          %682*1

% windowing
window_size = 7;
stride = window_size;
R = []; A=[]; V_line = [];
for offset = 1:stride:length(U)-window_size
    disp(['.....',num2str(int32(offset*100/(length(U)-window_size))),'%']);
    s = offset; e = window_size+offset;
    u = U(s:e); v = V(s:e); t = T(s:e);
    if all(u ~=0) && all(v ~=0)
        [r a] = weighted_linear_fit(v,u,t);
        R = [R r]; A = [A a]; V_line = [V_line mean(v)];

        %plot_polar_line_range(r,a, u(1)*cos(t(1)), u(end)*cos(t(end)) );
        %plot_polar_pts(u,t);
    else
        disp('0 vectors...pass')
    end
end

merger