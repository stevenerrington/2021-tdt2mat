data_csv = readtable('S:\Users\Current Lab Members\Steven Errington\temp\dajo_spikeData.csv');
data_dir = dir(fullfile('S:\Users\Current Lab Members\Steven Errington\temp\dajo_datacuration\SPK-figures\', '*.jpg'));

for neuronIdx = 1:size(data_csv,1)
    imgFileName_csv{neuronIdx,1} = [data_csv.cluster{neuronIdx} '-' data_csv.unitDSP{neuronIdx} '.jpg'];
end

for neuronIdx = 1:size(data_dir,1)
	imgFileName_dir{neuronIdx,1} = data_dir(neuronIdx).name;
end



missingEntries = setdiff(imgFileName_dir,imgFileName_csv);