function pts = plot_lines(r,a,x0,y0)
    % a's tail is on origin point
    syms x
    
    pts = [x0 y0];
    hold on;
    for i = 1:length(r)-1
        r1=r(i); r2=r(i+1);
        a1=a(i); a2=a(i+1);
        x_off = vpasolve(r1*sin(a1)+(-1/tan(a1))*(x-r1*cos(a1))...
            ==r2*sin(a2)+(-1/tan(a2))*(x-r2*cos(a2)),x);
        y_off = r1*sin(a1)+(-1/tan(a1))*(x_off-r1*cos(a1));
        subs(y_off);
        
        plot(x_off,y_off,'o');
        
        pts = [pts;double(x_off) double(y_off)];
        
        pt1 = pts(i,1); pt2 = pts(i+1,1);
        
        if pt2 < pt1
            tmp = pt1;
            pt1 = pt2;
            pt2 = tmp;
        end
        
        fplot(r1*sin(a1)+(-1/tan(a1))*(x-r1*cos(a1)),[pt1 pt2]);
    end

    %disp('Slope is'); disp(-1/tan(a));
    %disp('y-offset is'); disp(r*sin(a)+r*cos(a)/tan(a));

    %axis([0 1 0 0.5])
    title('Output: Extracted lines')
    daspect([1 1 1])
    hold off;
    saveas(gcf,'Extracted_lines.png');
end