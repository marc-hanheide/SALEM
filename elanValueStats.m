% function res=elanValueStats(elan,tier)
%
% calculates statistics for _one_ tier in elan file
% 
% arguments: elan: name of elan file struct
%            tier: _one_ tier structure 
%
% example
% perTierStats=elanValueStats(elan, elan.tiers.Blickrichtung_Schokou)
% case 1: "extend" (3)
% CCCCCCCCCCCCCC
%    RRRRRRR
% case 2: "end extends" (5)
%       CCCCCCCC
%    RRRRRRR
% case 3: "begin extends" (9)
%  CCCCCC
%    RRRRRRR
% case 4: "include" (17)
%     CCCC
%   RRRRRRRRR
function res=elanValueStats(elan,tier)
% compute for each value

% get all annotation values 'anno_xyz'
structIDs = correctStructID({tier.value});
if (~isempty(structIDs))
	values=unique(sort(structIDs));
	res.uniqueValues=char(values); % all unique annotation values
	res.numberUniques=length(values);
	res.predecessorTransitionMatrix=zeros(length(values));
	res.successorTransitionMatrix=zeros(length(values));
	res.summedSliceDuration=sum([elan.tiers.AnnotationValid.duration]); %duration of all parts of slice together
	% for each annotation value
	for i=1:length(values);
		structID=values{i};
		
		cf=[(cellfun(@(x) (strcmp(correctStructID(x),values{i})), {tier.value}))];
		selectedIndices=find(cf);% all indices of annotations that match the actual value

		% individual durations
		selectedDurations=[tier(selectedIndices).duration]';
		res.perValueStat.(structID).durations=(selectedDurations);
		
		% descriptive statistics for this annotation value
		res.perValueStat.(structID).count=length(selectedDurations);
		res.perValueStat.(structID).duration_sum=sum(selectedDurations);
		res.perValueStat.(structID).duration_min=min(selectedDurations);
		res.perValueStat.(structID).duration_max=max(selectedDurations);
		res.perValueStat.(structID).duration_median=median(selectedDurations);
		res.perValueStat.(structID).duration_mean=mean(selectedDurations);
		res.perValueStat.(structID).duration_var=var(selectedDurations);
		res.perValueStat.(structID).duration_std_deviation=sqrt(res.perValueStat.(structID).duration_var);
		
		if (~isempty(selectedIndices))
		% descriptive statistics for timeseries analysis
		if (isfield(tier(selectedIndices(1)),'firstextremum'))
			res.perValueStat.(structID).firstextremum = [tier(selectedIndices).firstextremum]';
			res.perValueStat.(structID).numextrema = [tier(selectedIndices).numextrema]';
			res.perValueStat.(structID).freqextrema = [tier(selectedIndices).freqextrema]';
			res.perValueStat.(structID).absextremum = [tier(selectedIndices).absextremum]';
		end%
		end%if
		
		% overlap of current annotation value with whole slice
		res.perValueStat.(structID).sliceOverlapPercentage=sum([tier(selectedIndices).overlapSeconds])/res.summedSliceDuration;
		res.perValueStat.(structID).sliceOverlapsSeconds=[tier(selectedIndices).overlapSeconds]';
		res.perValueStat.(structID).slice_PercAndCountFullExtends=[nnz(bitand([tier(selectedIndices).overlapCase],2))/length(selectedDurations), nnz(bitand([tier(selectedIndices).overlapCase],2))];
		res.perValueStat.(structID).slice_PercAndCountEndExtends=[nnz(bitand([tier(selectedIndices).overlapCase],4))/length(selectedDurations), nnz(bitand([tier(selectedIndices).overlapCase],4))];
		res.perValueStat.(structID).slice_PercAndCountBeginExtends=[nnz(bitand([tier(selectedIndices).overlapCase],8))/length(selectedDurations), nnz(bitand([tier(selectedIndices).overlapCase],8))];
		res.perValueStat.(structID).slice_PercAndCountIncluded=[nnz(bitand([tier(selectedIndices).overlapCase],16))/length(selectedDurations), nnz(bitand([tier(selectedIndices).overlapCase],16))];
		
		
		% check, that the first annotation does not have a predecessor
		% TODO (for every file!)
		if (nnz(selectedIndices==1)>0)
			predAllCount=length(selectedIndices)-1;
		else
			predAllCount=length(selectedIndices);
		end;
		for j=1:length(values)
			% find predecessors
			preStructID=values{j};
			preCf=[(cellfun(@(x) (strcmp(correctStructID(x),values{j})), {tier.value}))];
			preSelectedIndices=find(preCf);
			[a,b]=meshgrid(preSelectedIndices,selectedIndices-1);
			predec=nnz(max(a==b,[],2));
			
			% check, that the last annotation does not have a successor
			% TODO (for every file!)
			if (nnz(preSelectedIndices==length(preCf))>0)
				succAllCount=length(preSelectedIndices)-1;
			else
				succAllCount=length(preSelectedIndices);
			end;
			
			
			res.perValueStat.(structID).predecessor_counts.(preStructID)=predec;
			res.perValueStat.(structID).predecessor_allCount=predAllCount;
			res.perValueStat.(structID).predecessor_prob.(preStructID)=predec/predAllCount;
			
			res.perValueStat.(preStructID).successor_counts.(structID)=predec;
			res.perValueStat.(preStructID).successor_allCount=succAllCount;
			res.perValueStat.(preStructID).successor_prob.(structID)=predec/succAllCount;
			% encode the probabilities in a table:
			%   column index is always the FROM annotation, row the TO
			%   annotation
			res.predecessorTransitionMatrix(i,j)=predec/predAllCount;
			res.successorTransitionMatrix(i,j)=predec/succAllCount;
		end%for
	end%for
	
	
	
	try
		if (isfield(res,'perValueStat'))
			fn=fieldnames(res.perValueStat);
			
			res.ttest_pvalue_duration=-ones(length(fn));
			res.ttest_tstat_duration=-ones(length(fn));
			res.ttest_degfree_duration=-ones(length(fn));
			res.ttest_pvalue_sliceOverlapTime=-ones(length(fn));
			res.ttest_tstat_sliceOverlapTime=-ones(length(fn));
			res.ttest_degfree_sliceOverlapTime=-ones(length(fn));
			
			
			for i=1:length(fn);
				for j=1:length(fn);
					di=res.perValueStat.(fn{i});
					dj=res.perValueStat.(fn{j});
					[~,res.ttest_pvalue_duration(i,j),~,stats]=ttest2(di.durations, dj.durations);
					res.ttest_tstat_duration(i,j)=stats.tstat;
					res.ttest_degfree_duration(i,j)=stats.df;
					[~,res.ttest_pvalue_sliceOverlapTime(i,j),~,stats]=ttest2(di.sliceOverlapsSeconds, dj.sliceOverlapsSeconds);
					res.ttest_tstat_sliceOverlapTime(i,j)=stats.tstat;
					res.ttest_degfree_sliceOverlapTime(i,j)=stats.df;
				end%for
			end%for
		else
			warning ('no fieldnames found');
		end%if
	catch exc
		warning(['could not perform t-tests... probably Statistics Toolbox is not installed? The rest of the statistics is still done!']);
		%warning(exc.getReport);
		%rethrow exc;
	end%try
else
	res = struct();
	warning('ValueStats:noannotations','no annotations found');
end%if

% warn if you are using more than one elan File at once
if (length(elan.tiers.ElanFile) > 1)
	% TODO fix bug with transition probabilities using 'ElanFile' annotations
	warning('it appears that you are using more than one elan file at once, please note that there is a bug in the calculation of successor/predecessor transition probabilities at every transition from one elan file to the next that remains to be fixed!');
end

%% private function correctStructID
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
