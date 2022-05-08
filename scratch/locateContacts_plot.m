clear all; clc;


load('2021-dajo-datamap.mat');

gridZero = 7;
gridMap = zeros(gridZero+gridZero,gridZero+gridZero,20000);
nChannels = 32;
count = 0;

for sessionIdx = 1:size(dajo_datamap,1)
    
    if strcmp(dajo_datamap.animalInfo(sessionIdx).monkey,'darwin')
        for probeIdx = 1:dajo_datamap.nElectrodes(sessionIdx)
            
            grid_ap = round(dajo_datamap.neurophysInfo{sessionIdx,1}.grid(probeIdx,1));
            grid_ml = round(dajo_datamap.neurophysInfo{sessionIdx,1}.grid(probeIdx,2));
            depth = dajo_datamap.neurophysInfo{sessionIdx,1}.depth(probeIdx,:);
            spacing = dajo_datamap.neurophysInfo{sessionIdx,1}.spacing(probeIdx,:);
            
            clear grid_dv
            grid_dv = depth-spacing*(nChannels-1):spacing:depth;
            grid_dv = grid_dv(grid_dv > 0);
            
            gridMap(grid_ap+gridZero,grid_ml+gridZero,grid_dv) =...
                gridMap(grid_ap+gridZero,grid_ml+gridZero,grid_dv) + 1;
            
                
            for ii = 1:length(grid_dv)
               count = count + 1;      
               contact_xyz (count,:) = [grid_ap , grid_ml, grid_dv(ii)];
            end
            
            
        end
        
    end
    
end

%% Compute density
xyz = contact_xyz;
% Put points into 3D bins; xyzBinNum is an nx3 matrix containing
% the bin ID for n values in xyz for the [x,y,z] axes.
nBins = 25;  % number of bins
xbins = linspace(min(xyz(:,1)),max(xyz(:,1))*1,nBins+1);
ybins = linspace(min(xyz(:,2)),max(xyz(:,2))*1,nBins+1);
zbins = linspace(min(xyz(:,3)),max(xyz(:,3))*1,nBins+1);
xyzBinNum = [...
    discretize(xyz(:,1),xbins), ...
    discretize(xyz(:,2),ybins), ...
    discretize(xyz(:,3),zbins), ...
    ];

% bin3D is a mx3 matrix of m unique 3D bins that appear 
% in xyzBinNum, sorted.  binNum is a nx1 vector of bin
% numbers identifying the bin for each xyz point. For example,
% b=xyz(j,:) belongs to bins3D(b,:).
[bins3D, ~, binNum] = unique(xyzBinNum, 'rows');

% density is a mx1 vector of integers showing the number of 
% xyz points in each of the bins3D. To see the number of points
% in bins3D(k,:), density(k).  
density = histcounts(binNum,[1:size(bins3D,1),inf])'; 

% Compute bin centers
xbinCnt = xbins(2:end)-diff(xbins)/2;
ybinCnt = ybins(2:end)-diff(ybins)/2;
zbinCnt = zbins(2:end)-diff(zbins)/2;


%%
figure;
scatter3(...
    xyz(:,1), ...
    xyz(:,2), ...
    xyz(:,3), ...
    25, 'w','filled','MarkerFaceAlpha',0.5)
hold on
grid off
box off

xlim([min(xbins), max(xbins)])
ylim([min(ybins), max(ybins)])
zlim([min(zbins), max(zbins)])

% xz plane density
[xm,zm] = ndgrid(xbins, zbins);
xyCount = histcounts2(xyz(:,1),xyz(:,3), xbins,zbins);
surf(xm,max(ylim())*ones(size(xm)),zm,xyCount,'FaceAlpha',.8)

% yz plane density
[ym,zm] = ndgrid(ybins, zbins);
yzCount = histcounts2(xyz(:,2),xyz(:,3), ybins,zbins);
surf(max(xlim())*ones(size(xm)),ym,zm,yzCount,'FaceAlpha',.8)

% xy plane density
[xm,ym] = ndgrid(xbins, ybins);
xzCount = histcounts2(xyz(:,1),xyz(:,2), xbins,ybins);
surf(xm,ym,max(zlim())*ones(size(xm)),xyCount,'FaceAlpha',.8)


set(gca,'LineWidth',3)
box on
maxCount = max([xyCount(:);xyCount(:);xzCount(:)]);
set(gca,'colormap',inferno,'CLim',[0,25],'ZDir','Reverse')
cb = colorbar(); 
ylabel(cb,'Number of contacts')


