function plot_polar_line_range(r,a,from,to)
    syms x
    if from > to
        temp = from;
        from = to;
        to =temp;
    end
    
    fplot(r*sin(a)+(-1/tan(a))*(x-r*cos(a)),[from to]);

    %disp('Slope is'); disp(-1/tan(a));
    %disp('y-offset is'); disp(r*sin(a)+r*cos(a)/tan(a));

    %axis([0 1 0 0.5])
end