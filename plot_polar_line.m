function plot_polar_line(r,a)
    syms x y
    fplot(r*sin(a)+(-1/tan(a))*(x-r*cos(a)));

    disp('Slope is'); disp(-1/tan(a));
    disp('y-offset is'); disp(r*sin(a)+r*cos(a)/tan(a));

    %axis([0 1 0 0.5])
end