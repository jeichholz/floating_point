function plot_on_number_line(x,tickmarks)
%A simple function to plot an array of numbers on the real number line.
%x is expected to be sorted from smallest to largest. 
%if tickmarks is specified, then the labels along the x-axis are set to the
%values in tickmarks. 
    tick_height=0.05;
    real_line_width=2;
    
    box;
    hold on;
    plot([x(1) x(end)],[0,0],'k','LineWidth',real_line_width);
    for xv = reshape(x,1,[])
        plot([xv,xv],[tick_height,-tick_height],'k');
    end
    axis(double([x(1) x(end) -0.5 0.5]));
    set(gca,'YColor','w');
    set(gca,'Zcolor','w');
    set(gca,'YTick',[]);
    if exist('tickmarks','var')
        set(gca,'XTick',double(tickmarks));
    end
end