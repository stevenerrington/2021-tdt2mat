Locationof for Channel Map file for Kilosort
Variables:
chanMap : nx1 -> N channels 
connected: nx1 -> vector of 0|1
xcoords: nx1 -> location on grid
ycoords: nx1 -> distance between channels in microns
kcoords: nx1 -> group number for the channel. Example if we use 2 probes of 16 channels ech, then 
         chanMap = 1:16*2
         kcoords = [ones(16,1); ones(16,1).*2];
fs: sampling frequency