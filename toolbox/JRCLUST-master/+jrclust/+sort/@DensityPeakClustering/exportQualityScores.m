function success = exportQualityScores(obj, zeroIndex, fGui)
    %EXPORTQUALITYSCORES Export cluster quality scores to CSV
    if nargin < 2
        zeroIndex = 0;
    end
    if nargin < 3
        fGui = 0;
    end

    ID = (1:obj.nClusters)';
    SNR = obj.unitSNR(:);
    centerSite = obj.clusterSites(:) - double(zeroIndex);
    nSpikes = obj.unitCount(:);
    xPos = obj.clusterCentroids(:, 1);
    yPos = obj.clusterCentroids(:, 2);
    uVmin = obj.unitPeaksRaw(:);
    uVpp = obj.unitVppRaw(:);
    IsoDist = obj.unitIsoDist(:);
    LRatio = obj.unitLRatio(:);
    ISIRatio = obj.unitISIRatio(:);
    note = obj.clusterNotes(:);

    filename = jrclust.utils.subsExt(obj.hCfg.configFile, '_quality.csv');

    try
        table_ = table(ID, SNR, centerSite, nSpikes, xPos, yPos, uVmin, uVpp, IsoDist, LRatio, ISIRatio, note);
        writetable(table_, filename);
    catch ME
        warning('Failed to export: %s', ME.message);
        success = 0;
        return;
    end

    if obj.hCfg.verbose
        disp(table_);
        helpText = {sprintf('Wrote to %s. Columns:', filename), ...
                    sprintf('\tColumn 1: ID: Unit ID'), ...
                    sprintf('\tColumn 2: SNR: |Vp/Vrms|; Vp: negative peak amplitude of the peak site; Vrms: SD of the Gaussian noise (estimated from MAD)'), ...
                    sprintf('\tColumn 3: centerSite: Peak site number which contains the most negative peak amplitude'), ...
                    sprintf('\tColumn 4: nSpikes: Number of spikes'), ...
                    sprintf('\tColumn 5: xPos: x position (width dimension) (center-of-mass'), ...
                    sprintf('\tColumn 6: yPos: y position (depth dimension) (center-of-mass, referenced from the tip'), ...
                    sprintf('\tColumn 7: uVmin: Min. voltage (uV) of the mean raw waveforms at the peak site (microvolts)'), ...
                    sprintf('\tColumn 8: uVpp: peak-to-peak voltage (microvolts)'), ...
                    sprintf('\tColumn 9: IsoDist: Isolation distance quality metric'), ...
                    sprintf('\tColumn 10: LRatio: L-ratio quality metric'), ...
                    sprintf('\tColumn 11: ISIRatio: ISI-ratio quality metric'), ...
                    sprintf('\tColumn 12: note: user comments')};

        cellfun(@(x) fprintf('%s\n', x), helpText);
        if fGui
            jrclust.utils.qMsgBox(helpText);
        end
    end

    success = 1;
end