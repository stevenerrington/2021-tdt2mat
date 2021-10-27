function [] = plotZoom(hAxes, varargin)
%ZOOMPLOT Clicking on an axes (subplot) zooms the plot. Click again to
%un-zoom
%   Example:
%     figure()
%     for ii = 1:4 % make 2 by 2 sub plots
%        subplot(2,2,ii)
%        plot(1:100, rand(10,100));
%        thisPlot.pos = get(gca,'Position');
%        thisPlot.zoom = 0;
%        set(gca,'UserData',thisPlot);
%        set(gca,'ButtonDownFcn',@plotZoom);
%     end
%
%  Schall Lab, Department of Psychology, Vanderbilt University
   
   thisPlot = get(hAxes,'UserData');
    if thisPlot.zoom == 0
        thisPlot.zoom=1;
        set(hAxes,'Position',[0.2 0.2 0.7 0.7]);
        set(findobj(hAxes,'Type','text'),'FontSize',15);
        uistack(hAxes,'top')
        set(hAxes,'UserData',thisPlot);
    else
        thisPlot.zoom=0;
        set(hAxes,'Position',thisPlot.pos);
        set(findobj(hAxes,'Type','text'),'FontSize',10);
        uistack(hAxes,'bottom')
        set(hAxes,'UserData',thisPlot);
    end
end

