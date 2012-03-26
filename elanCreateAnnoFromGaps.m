% function elan=elanCreateAnnoFromGaps(elan, oldtiername, newtiername, gaps, newAnnoNames)
%
% NEEDS    :
% USED BY  :
%%
% ARGUMENTS: elan: eaf file imported by elanReadFile.m
%            oldtiername: tiername of elan.tiers
%            newtiername: new tiername for elan.tiers
%            gaps: case1: cell array (of cellarrays) of existing annotations in oldtiername
%                  case2: 'all'
%            newAnnoNames: case1: cell array new annotations for newtiername
%                          case2: beginning of name of new annotations
% RETURNS  : newelan: elan struct with new tier and annotations
%%
% adierker / 2011-03-13
%
%% USAGE:
% case 1:  %close specific gaps
% elan=elanCreateAnnoFromGaps(eaffile,'Phasen','newtier',{{'Phase0','Phase1'},{'Phase1','Phase0'}},{'intro1','task1'});
% case 2:  %close all gaps
% elan=elanCreateAnnoFromGaps(eaffile,'isr_romulus_utterances_001','newtier','all','pause_');

% feature request: should be possible that all new annotations have identical names
%% implementation
function newElan=elanCreateAnnoFromGaps(elan, oldtiername, newtiername, gaps, newAnnoNames)

% test if oldtiername exists
if (~isfield(elan.tiers,oldtiername))
	warning ('old tier name does not exist');
end%if

% test if newtiername is already given
if (isfield(elan.tiers,newtiername))
	warning ('new tier name already exists.... proceeding/overwriting in 30 seconds, use ctrl-c to avoid overwriting. Note: you can call the function with preceding rmfield to avoid this warning.');
	pause(30)
end%if

newtier = [];

% sort old annotations in timeline to ensure correct neighbors
[~,index] = sort([elan.tiers.(oldtiername).start]);
oldannos = elan.tiers.(oldtiername)(index);

if (iscell(gaps))
	% if we are closing specific gaps (case 1)
	
	if (~iscell(gaps{1}))
		% if there is only one pair of annotations in gaps variable convert to cell array of
		% cell array
		gaps = {gaps};
	end
	
	% now, there is more than one gap (cellarray of cellarrays)
	if (length(gaps)~=length(newAnnoNames))
		error ('length of gaps and newAnnoNames differ');
	end%if
	for annoid = 1:length(gaps)
		% for each cellarray in gaps compute the gap annotation
		start = gaps{annoid}(1);
		stop = gaps{annoid}(2);
		
		% compute start/stop indices of gap annotations
		% (for the following see function_handle (@) help text)
		% string-compare all start.value(s) with stop argument(s);
		% max evaluates if at least one strcmp was 1;
		cfstart = [(cellfun(@(x) (max(strcmp(strtrim(x),start))), {oldannos.value}))];
		cfstop = [(cellfun(@(x) (max(strcmp(strtrim(x),stop))), {oldannos.value}))];
		% find gets all indices for the cases where strcmp was 'true'
		startIndices = find(cfstart);
		stopIndices = find(cfstop);
		if (isempty(startIndices) ||isempty(stopIndices) )
			warning('At least one of the gaps mismatches all your annotations: %s %s',start{1},stop{1});
			%celldisp(start)
			%celldisp(stop)
		end%if
		
		% create new annoations with nearest neighbors
		for i=1:length(startIndices)
			startid = startIndices(i);
			stopIndices = stopIndices(stopIndices>startIndices(i));% ignore matches to the left
			if (numel(stopIndices)~=0)
				for j=1%:length(stopIndices) %only next neighbor
					stopid = stopIndices(j);
					anno = struct();
					% now fill the tier struct with the values
					anno.start = oldannos(startid).stop;
					anno.stop = oldannos(stopid).start;
					%if (anno.stop > anno.start)
					anno.duration = anno.stop - anno.start;
					anno.value = newAnnoNames{annoid};
					anno.startTSR = 'this annotation does not exist in your .eaf file';
					anno.stopTSR = 'this annotation does not exist in your .eaf file';
					anno.overlapCase = 0;
					anno.overlapSeconds = anno.duration;
					
					% add new tier to vector of structs
					if (anno.start>=0)
						newtier = [newtier anno];
						%minStart = min(minStart,anno.start);
						%maxStop = max(maxStop,anno.stop);
					end%if
					
				end%for
			end%if
		end%for
	end%for	
else
	% if we are creating annotations for non-explicit gaps (all gaps between all
	% annotations) (case 2)
	
	if (length(oldannos) >= 2) % if there is a neighbor
		newtier = [];
		
		% create new anno between each two neighbors of old annotations
		for i = 1:length(oldannos)-1 %current annotation
			j = i+1; %neighbor of current annotation
			anno = struct();
			% now fill the tier struct with the values
			anno.start = oldannos(i).stop;
			anno.stop = oldannos(j).start;
			anno.duration = anno.stop - anno.start;
			anno.value = strcat(newAnnoNames,num2str(i));
			anno.startTSR = 'this annotation does not exist in your .eaf file';
			anno.stopTSR = 'this annotation does not exist in your .eaf file';
			anno.overlapCase = 0;
			anno.overlapSeconds = anno.duration;
			
			% add new tier to vector of structs
			if (anno.start>=0)
				newtier = [newtier anno];
				%minStart = min(minStart,anno.start);
				%maxStop = max(maxStop,anno.stop);
			end%if
		end%for
	else
		warning('number of annotations in tier %s < 2',oldtiername)
	end%if
end%if

% now add the new tier to the old struct
newElan = elan;
newElan.tiers.(newtiername) = newtier;

end%function

% suppress matlab code warnings
%#ok<*WNTAG>
