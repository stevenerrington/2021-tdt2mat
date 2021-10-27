
primaryTable;
% location of columns in table
modulationColIdx = 6:13;

data = primaryTable;
colNames = data.Properties.VariableNames;
modulationColNames = colNames(6:13);

% build the truth-table you want
combs = table();
% Values format: 
% [Visual Error PositiveConflict NegativeConflict Disable Enable Gain Loss]
% Visual only
combs=array2table([true false false false false false false false],'VariableNames',modulationColNames,'RowNames',{'Visual'});
% VisualError only
combs=[combs;...
    array2table([true true false false false false false false],'VariableNames',modulationColNames,'RowNames',{'VisualError'})];
% VisualPositiveConflict only
combs=[combs;...
       array2table([true false true false false false false false],'VariableNames',modulationColNames,'RowNames',{'VisualPositiveConflict'})];
% VisualNegativeConflict only
combs=[combs;...
       array2table([true false false true false false false false],'VariableNames',modulationColNames,'RowNames',{'VisualNegativeConflict'})];
% VisualDisable only
combs=[combs;...
       array2table([true false false false true false false false],'VariableNames',modulationColNames,'RowNames',{'VisualDisable'})];
% VisualEnable only
combs=[combs;...
       array2table([true false false false false true false false],'VariableNames',modulationColNames,'RowNames',{'VisualEnable'})];
% VisualGain only
combs=[combs;...
       array2table([true false false false false false true false],'VariableNames',modulationColNames,'RowNames',{'VisualGain'})];
% VisualLoss only
combs=[combs;...
       array2table([true false false false false false false true],'VariableNames',modulationColNames,'RowNames',{'VisualLoss'})];

% Create needed struct (or need table?)   
rowNames = combs.Properties.RowNames;
Z = struct();
for ii = 1:numel(rowNames)
    rowName = rowNames{ii};
    Z.(rowName) = sum(ismember(data(:,modulationColIdx),combs(rowName,:),'rows'));
end


% 


