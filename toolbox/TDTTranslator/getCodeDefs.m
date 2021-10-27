function [code2Name, name2Code, codeTable] = getCodeDefs(codesFile)
%GETCODEDEFS Parse files conatining declarations for Event or Info codes.
%
%   codesFile : File that contains declarations for (Code, Name) pairs.
%               This file can be one of the following files that contains
%               *specific* matching expressions to extract [Code-Name]
%               pairs. Ensure that there are no duplicate codes or
%               different names for same code. If there are duplicates, the
%               call will issue a warning and proceed. This should be
%               treated as an error in experiment setup files.
%               Matching expressins are different for different files:
% <html>
% <table><th><td>test1</td></th><tr><td>blah</td></tr></table>
% </html>
% ________________________________________________________________________
% |   Filename    |  Matching Expression                                 |
% ------------------------------------------------------------------------
% |INFOS.pro      |'^\s*Event_fifo.*InfosZero\s*\+\s*\(*(\w*)\s*.*;'     |
% |EVENTDEF.pro   |'^declare hide constant\s+([A-Z]\w*)\s*=\s*(\d{1,4});'|
% |....rigXXXXX.m |'EV\.([A-Z]\w*)\s*=\s*(\d{1,4});'                     |
% ------------------------------------------------------------------------
%
% Example:
% codesFile = 'data/Joule/TEMPO/currentProcLib/EVENTDEF.pro';
% [evCodec.code2Name, evCodec.name2Code] = getCodeDefs(codesFile);
%
% See also GETRELCODES, VERIFYEVENTCODES, TDTEXTRACTBEHAVIOR
    
    if contains(codesFile,'INFOS')
        [ev.code, ev.name] = parseInfosCodes(codesFile);   
    elseif contains(codesFile,'EVENTDEF') % EVENDTDEF.pro file
        [ev.code, ev.name] = parseEventCodes(codesFile);
    else
        error('Unknown codes file %s',codesFile);
    end    
    % fix duplicate names: ?
     code2Name = containers.Map(ev.code, ev.name);
     name2Code = containers.Map(ev.name, ev.code);
     
     codeTable = table([code2Name.values]',cell2mat(code2Name.keys)', 'VariableNames',{'name','code'});
end

function [codes, names] = parseEventCodes(codeFile)
    content = fileread(codeFile);
    tokens = regexp(content,'constant\s+([A-Z]\w*)\s*=\s*(\d{1,4});','tokens');
    tokens = [tokens{:}];
    tokens = reshape(tokens, [2, numel(tokens)/2])';
    names = tokens(:,1);
    codes = cellfun(@str2num,tokens(:,2));
    codesGt3000 = find(codes>3000);
    if ~isempty(codesGt3000)
        warning(sprintf('There are Event codes greater than 3000.\nIf these are commented out, please *REMOVE* commented out line(s)\n')); %#ok<SPWRN>
        disp(table(names(codesGt3000),codes(codesGt3000),...
             'VariableNames',{'EventName','EventCode'}));
        warning(sprintf('EVENTCODES greater than 3000 are NOT Processed...\n')); %#ok<SPWRN>  
    end
    % Upper camel case names
    names = upperCamelCase(names);
    % remove leading Trl prefix
    names = regexprep(names,'^Evt',''); 
    % add trailing underscore
    names = regexprep(names,'([a-z])$','$1_');
end

function [codes, names] = parseInfosCodes(codesFile)
    content = fileread(codesFile);
    content = regexprep(content,'InfosZero\s*\+\s*|abs\(|\(|\s*\+\s*\d*|\);','');
    content = regexprep(content,'Int|spawnwait|spawn','');
    % for new Proclib code:(Idempotent for other INFOS?)
    content = regexprep(content,'INFOS_ZERO|int|\s*WAIT_INFOS\n*','');
    % New TEMPO code infos pattern
    sendEvtRegEx = 'SEND_INFO_EVT(\w*)|SEND_INFO_REL_TIME(\w*)';
    % Check both patterns:
    names = regexp(content,sendEvtRegEx,'tokens');
    if isempty(names)
        names = regexp(content,sendEvtRegEx,'tokens');
    end
    if isempty(names)
        sendEvtRegEx = 'SEND_EVT(\w*)';
        names = regexp(content,sendEvtRegEx,'tokens');
    end
    if isempty(names)
        %setEvtRegEx = 'Set_event\]\s*=\s*(\w*[ +]*\w*)';
        sendEvtRegEx = 'Set_event\]\s*=\s*(\w*)';
        names = regexp(content,sendEvtRegEx,'tokens');
    end
    names = [names{:}]'; 
    names = names(~cellfun(@isempty,names));
    names = names(~ismember(names,{'StartInfos_','EndInfos_'}));
    codes = (1:numel(names))';
    % Upper camel case names
    names = upperCamelCase(names);
    % remove leading Trl prefix
    names = regexprep(names,'^Trl','');
end

function [ccNames ]= upperCamelCase(names)
    % check underscores: remove and convert to upper camel case
    % see: https://www.mathworks.com/matlabcentral/answers/107307-function-to-capitalize-first-letter-in-each-word-in-string-but-forces-all-other-letters-to-be-lowerc
    names = char(join(lower(strcat('_',names')),'|'));
    regexForUnderscore = '(?<=_)[a-z]';
    idxForUpper = regexp(names,regexForUnderscore,'start');
    names(idxForUpper) = upper(names(idxForUpper));
    ccNames = split(regexprep(names,'_',''),'|');
end
