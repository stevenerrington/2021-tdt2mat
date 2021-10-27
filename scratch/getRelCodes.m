function [tblCounts] = getRelCodes(refCode,tdtCodes, evCodec)
%GETRELCODES Get summary of code counts before and after reference Code
%   
%   refCode : Reference event code used to get events before / after
%   tdtCode : all tdtEvents (note only EVENT CODES so >= 3000 set to empty
%   evCodec : A struct of Map containers for mapping code <-> name (got the
%             running getDoeDefs.m). Has 2 fields:
%             .name2Code : a containers.Map object for name -> code mapping
%             .code2Name : a containers.Map object for code -> name mapping
%   
%    tblCounts : A struct wher each field is a table of unique code counts.
%                The row names of thew table are codes_name.  Unknown codes
%                are also counted
% 
% see also GETCODEDEFS, VERIFYEVENTCODES, TDTEXTRACTBEHAVIOR

  % if first or last eventCode is the ref code
  tdtCodes = [NaN;tdtCodes;NaN]; 
  iRefCodes = find(tdtCodes==refCode);
  codesBeforeRef = tdtCodes(iRefCodes - 1);
  codesAfterRef = tdtCodes(iRefCodes + 1);
  
  uniqCodes = unique([codesBeforeRef;codesAfterRef]);
  uniqCodes(isnan(uniqCodes))=[];
  
  tblCounts = table();
  
  tblCounts.(num2str(refCode,'before_%d')) = arrayfun(@(x) sum(codesBeforeRef == x),uniqCodes );
  tblCounts.(num2str(refCode,'after_%d')) = arrayfun(@(x) sum(codesAfterRef == x),uniqCodes );
  rowNames = cell(numel(uniqCodes),1);
  for ii = 1:numel(uniqCodes)
      x = uniqCodes(ii);
      try
          rowNames{ii} = [num2str(x) '_' evCodec.code2Name(x)];
      catch 
          rowNames{ii} = [num2str(x) '_' 'UNKNOWN_CODE_IN_EVENTDEF.pro'];
      end     
  end
  
  %tblCounts.Properties.RowNames = arrayfun(@(x) [num2str(x) '_' evCodec.code2Name(x)],uniqCodes,'UniformOutput',false);
  tblCounts.Properties.RowNames = rowNames;

end

