1. Clone JRCLUST code from github
        git clone https://github.com/JaneliaSciComp/JRCLUST

2. Open Matlab and add the following (including sub-folders) to matklabpath
        [project-dir]/ephys
        [project-dir]/TDTSDK
        [project-dir]/toolbox
        Not needed
        [project-dir]/beh translates events/eyes for the new CMD protocol
3. Convert *_Wav1_*.sev files to binary file.
        convertTdt2Bin(ops) : ops.dataDir [monk]/sessionDir
                              ops.fbinary fullfile Path: Usually ops.dataDir/sessionName.bin
                              ops.tdtFilePattern File pattern for TDT wav files ex. '*Wav1_*.sev'

4. Before converting take a peek at convertTdt2Bin.m for how it is scaling the single values since that factor will be needed for spike sorting

5. Jrclust sorting:
    Navigate to where you want to save the processed data
    Create the [dataProcessed]/[monk]/.../sessionName/jrclust
    copy ephys/master_jrclust_changeme.prm to the the above dir and rename as master_jrclust.prm
    Edit master_jrclust.prm (note it will appear as if it is a matlab m file, but not matlab m-funtions run when this file is consumed.
         so [1:4] is invalid have to use [1,2,3,4]
    Check the JRCLUST documentation site for useage / parameters: https://jrclust.readthedocs.io/en/latest/usage/index.html
         
6. In Matlab add the JRCLUST location to matlabpath
        addpath('JRCLUST-DIR')

7. Navigate to [dataProcessed]/[monk]/.../sessionName/jrclust in Matlab 
        jrc('detect-sort','master_jrclust.prm')

8. Curate manually in JRCLUST:
        jrc('manual','master_jrclust.prm')

9. After done, run getJrclustSpikes to write spikes as familiar DSP01a... vars to Spikes.mat
        Check the getJrclustSpikes.m file to setup

    
