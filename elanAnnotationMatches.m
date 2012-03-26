% function res=elanAnnotationMatches(tier, matchingString)
%
% calculates the occurences of 'matchingString' in the annotations of 'tier' and 
% returns the number of matches. The match is ignoring the case (e.g.
% 'Biron' matches 'biron').
% 
% arguments: tier:              _one_ tier structure 
%            matchingString:    the string to search for (if it is a cell
%                               array, all the values are search for and
%                               results are reported separately
%
% example:
% s=elanAnnotationStats(e.tiers.SaySrv,'ich');
%
% res = 
%
%      matchingCount: 99
%         totalCount: 181
%    matchingPercent: 0.5470
%    matchingIndices: [1x99 double]
%
% example:
% res=elanAnnotationMatches(e.tiers.SaySrv,{' ist ' ' ich '})
%
% res = 
%
%    anno_ist: [1x1 struct]
%    anno_ich: [1x1 struct]
%res.anno_ich
%
% ans = 
%
%      matchingCount: 99
%         totalCount: 181
%    matchingPercent: 0.5470
%    matchingIndices: [1x99 double]


function res=elanAnnotationMatches(tier, pattern)
if (iscell(pattern)) 
    for i=1:length(pattern);
        res.(correctStructID(pattern{i}))=elanAnnotationMatches(tier, pattern{i});
    end;
else

    % compute for each value
    
    annos=lower({tier.value});
    
    matches=[];
    for i=1:length(annos);
        if (strfind(annos{i}, lower(pattern)))
            matches=[matches i];
        end;
    end;
    res.matchingCount = length(matches);
    res.totalCount= length(annos);
    res.matchingPercent = res.matchingCount / res.totalCount;
    res.matchingIndices = matches;
end;

function structID=correctStructID(in)
structID=regexprep(strtrim(in),'[^\w]|[äöüßÄÖÜ]','_');
%     structID = strrep(in, '.', '_');
%     structID = strrep(structID, '-', '_');
%     structID = strrep(structID, ' ', '_');
%     structID = strrep(structID, ',', '_');
%     structID = strrep(structID, ';', '_');
%     structID = strrep(structID, ':', '_');
%     structID = strrep(structID, ':', '_');
%         structID = strrep(structID, ':', '_');
%             structID = strrep(structID, ':', '_');

% add 'anno_' before annotation value
if (~isempty(structID))
	structID = strcat('anno_',structID);
	%	 else
	%		 warning ('empty tierID');
end
