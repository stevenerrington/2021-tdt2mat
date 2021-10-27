
%https://www.mathworks.com/matlabcentral/answers/408249-how-to-assign-individual-colors-to-grouped-and-stacked-elements-in-bar-chart
%Fix data structure
%set some input
Groups=6;
Stacks=5;
NumInGroup = 2;
groupLabels ={'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i'};
Data = rand(1,Groups*NumInGroup*Stacks);
%Data=permute(Data,[2 1 3])
Data=reshape(Data,Groups*NumInGroup, Stacks)

NumBars=Groups*NumInGroup;
%Plot
figure;hold on;
for i=1:Groups*NumInGroup
    h(i,1:Stacks)=bar([Data(i,:);nan(1,Stacks)],'stacked');
end
%Group and set xdata
x1=1:Groups
x0=x1-0.4;
x2=x1+0.4;
pos=[x0;x1]; %[x0;x1;x2];
xpos=pos(:)';
for i=1:Groups*NumInGroup
    set(h(i,:),'xdata',xpos(i))
end
set(h,'barwidth',0.4)
%Set labels
set(gca,'xtick',[1:Groups],...
    'xticklabels',groupLabels)
%Set colors
set(h(:,1),'facecolor',[.7 .7 .7])
set(h(1:9,2),'facecolor',[0 0 1])
set(h(10:end-9,2),'facecolor',[0.7 0.3 0.4])
set(h(end-8:end,2),'facecolor',[0 1 0])
set(h(1:3:end,3),'facecolor',[1 1 1])
set(h(2:3:end,3),'facecolor',[0.5 0.1 0.9])
set(h(3:3:end,3),'facecolor',[0 0 0])

