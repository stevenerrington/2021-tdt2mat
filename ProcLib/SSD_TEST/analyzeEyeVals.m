% PERL: remove alternate header lines....
% perl -ni.bak -e'print unless m/^\iXVolts/' xx.csv

fName = 'eyeValsTry1.csv';
%ssdTable = csvread(fName,1);

eyeTable = readtable(fName,'ReadVariableNames',true);
