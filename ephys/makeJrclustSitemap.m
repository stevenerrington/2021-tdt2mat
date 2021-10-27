nChan = 32;
chanSpacing = 100;

% 
siteMap = 1:nChan;
shankMap = ones(1,nChan);
siteLocs = [zeros(1,nChan); siteMap.*chanSpacing];

shankMapStr = ' % (formerly viShank_site) Shank ID of each site';
siteLocStr = '% (formerly mrSiteXY) Site locations (in micro-m) (x values in the first column, y values in the second column)';
siteMapStr = ' % (formerly viSite2Chan) Map of channel index to site ID (The mapping siteMap(i) = j corresponds to the statement ''site i is stored as channel j in the recording'')';


% paste the output strings in master_jrclust.prm
fprintf('\n********Copy and paste the output strings into')
fprintf('********master_jrclust.prm file\n');
temp = num2str(shankMap,'%i,');
fprintf('shankMap = [%s]; %s\n', temp(1:end-1),shankMapStr);
temp = num2str(siteLocs(:)','%i,%i;');
fprintf('siteLoc = [%s]; %s\n',temp(1:end-1),siteLocStr);
temp = num2str(siteMap,'%i,');
fprintf('siteMap = [%s]; %s\n', temp(1:end-1),siteMapStr);
fprintf('*********\n')