% read the elan file into a struct of tiers (single elan file)
elan=elanReadFile('VP01-face-1.eaf');

% read several files in one struct (multiple elan file)
elan=elanReadFile({'example.eaf','VP01-face-1.eaf'});
% you can ignore the warning about timeseries support if you don't intend to use it


%% exploring the struct/ working with the elan file
% (a) you can browse the struct using the Matlab GUI 
% (double-click on 'elan' variable in the workspace window)

% (b) you can explorte the struct using the command-line (some examples in the following)
elan.tiers 
	% ans =                  DLG: [] % <- this means no annotations in this tier
	%               MemoryLogger: []
	%                    PTA_mod: [1x318 struct] % <- this means 318 annotations in this tier
	%                     SaySrv: [1x181 struct]
	%                SpeechInput: [1x203 struct]
	%               PTA_mod_Loop: [1x184 struct]
	%                    ESV_mod: [1x225 struct]
	%                    HWC_mod: [1x18 struct]
	%                     CPDATA: [1x97 struct]
	%          biron_log_SyncLog: [1x3 struct]
	%              EmergencyStop: [1x6 struct]
	%            PersonSituation: [1x226 struct]
	%                   ACMI_sys: [1x10 struct]
	%                        BHG: [1x413 struct]
	%            AnnotationValid: [1x2 struct]   % you can ignore this (necessary for slicing
	%                   ElanFile: [1x2 struct]   % ... see help elanSlice)
	%               speech_human: [1x69 struct]
	%               speech_robot: [1x39 struct]
	%              phase_present: [1x26 struct]
	%              phase_waiting: [1x24 struct]
	%               phase_answer: [1x26 struct]
	%                phase_react: [1x26 struct]
	%     robot_says_object_name: [1x12 struct]
	%                    scene_1: [1x13 struct]
	%                    scene_2: [1x13 struct]
	%             Gesten_Schokou: [1x102 struct]
	%      Blickrichtung_Schokou: [1x122 struct]
	%            speech_category: [1x67 struct]
	%               Gesten_manja: [1x125 struct]

% list all annotation values of specific tier
elan.tiers.Blickrichtung_Schokou.value
% list all annotation durations of specific tier
elan.tiers.Blickrichtung_Schokou.duration

% look at one specific annotation (number 30) in a tier (which is here called
% 'speech_human')
elan.tiers.speech_human(30)
	% ans = 
	% 
	%       startTSR: 'ts496'
	%        stopTSR: 'ts498'
	%          start: 229.8800
	%           stop: 230.7100
	%       duration: 0.8300
	%          value: 'Ja.'



%% slicing your elan file(s)

% according to interval
slicedElan=elanSlice(elan, 10, 100);

% do it with several at once:
%   first slice starts at 10, end at 100, 
%   second starts at 200, ends at 400
slicedElan=elanSlice(elan, [10 200], [100 400]);

% Slicing with Tiers (taking the given tier as reference and slice definition)
% using all annotations of this tier
slicedElan=elanSlice(elan,elan.tiers.Blickrichtung_Schokou);

% slice with all annotations of a tier that have a certain value 
slicedElan=(elanSlice(elan,elan.tiers.Blickrichtung_Schokou,'2'));

% slice with all annotations of a tier that have any of these values '2' or '3'
slicedElan=(elanSlice(elan,elan.tiers.Blickrichtung_Schokou,{'2','3'}));


%% do some statistics on original or sliced ELAN file (again browse the result using the
%% GUI!
elanstats=elanDescriptives(elan);
% descriptives of the sliced annotations (all annotations that overlap the
% annotations in the reference tier)
sliceDescr=elanDescriptives(slicedElan);

% show the statistics on overlaps of the elan/slice definition (ordered by
% overlap definition)
elanstats.Blickrichtung_Schokou.slice_PercAndCountFullExtends
elanstats.Blickrichtung_Schokou.slice_PercAndCountEndExtends
sliceDescr.Blickrichtung_Schokou.slice_PercAndCountBeginExtends
sliceDescr.Blickrichtung_Schokou.slice_PercAndCountIncluded
% OVERLAP Definitions: (C= compared tier, R=reference tier)
    % case "FullExtends": (3)
    %  CCCCCCCCCCCCCC
    %     RRRRRRR
    % case "EndExtends": (5)
    %       CCCCCCCC
    %    RRRRRRR
    % case "BeginExtends": (9)
    %  CCCCCC
    %    RRRRRRR
    % case "Included": (17)
    %     CCCC
    %   RRRRRRRRR
   

%% analyse a specific tier according to the annotation values 
% (Blickrichtung_Schokou is the name of the tier):
vc=elanValueStats(elan, elan.tiers.Blickrichtung_Schokou);
vc=elanValueStats(slicedElan, slicedElan.tiers.Blickrichtung_Schokou);

% per-value stats
vc.perValueStat
vc.perValueStat.anno_3
% transition probabilities between values
% calculates what value precedes a given value
vc.predecessorTransitionMatrix
vc.successorTransitionMatrix


%% plot the original elan file
elanPlot(elan)
% or a sliced elan file
elanPlot(slicedElan)

%% create new annotations from gaps
% case 1: close specific gaps with specific name
newelan=elanCreateAnnoFromGaps(elan,'HWC_mod','MyNewTier',{{'BB:BasisProxyinitializationdone.','BB:FollowControlinitializationdone.'},{'SwitchedtonewinputPTA','SwitchedtonewinputTOP'}},{'NewAnnoOne','NewAnnoTwo'});
% case 2: close all gaps with sequential name
newelan=elanCreateAnnoFromGaps(elan,'HWC_mod','NyNewTier','all','NewAnno_');

%% _very_ rudimentary comparison values
[redundantCompTier,numRelevantAnnos]=elanCorrelateTiers(elan,'Gesten_manja','Gesten_Schokou',{'2','3'});
   % result: redundantCompTier = 1x34 struct array, numRelevantAnnos =   37
   % 
	% >> redundantCompTier(2)
	% ans =     startTSR: 'ts69'
	%            stopTSR: 'ts76'
	%              start: 2.0984e+03  <- start timestamp in compare tier
	%               stop: 2.1009e+03  <- stop timestamp in compare tier
	%           duration: 2.5600      <- anno duration in compare tier
	%        overlapCase: 9           <- overlapCase 9 = beginExtend (see help elanValueStats)
	%     overlapSeconds: 0.1400      <- number overlapping seconds
	%              value: '1mbh'      <- value of anno in compare tier
	%           refValue: '3'         <- value of anno in reference tier
	%        refDuration: 5.8100      <- anno duration in reference tier
	%           refStart:             <- start timestamp in reference tier
   %            refStop:             <- stop timestamp in reference tier
   %         startOnset:             <- (anno start in tier2) - (anno start von tier1)
   %         stopOffset:             <- (anno stop in tier2) - (anno stop von tier1)        
	%       overlapMatch: 1           <- 1: match, 0: different values
	%                                    to come: ]0,1[ for building of confusion matrix 
	%                                    (which values are annotated mostly when wrong)

%% working with timeseries data:
elanTS = elanReadFile('2010-04-22-vpen01.eaf')
% elanTS =   tiers: [1x1 struct]
%      linkedFiles: [1x1 struct]
%     eaf_basetime: NaN

% elanTS.tiers =    aenderungs_events: [1x10 struct]
% 							experiment_phase: [1x8 struct]
% 						 rubbish_annotation: [1x31 struct] 
% 									 csv_1_all: [1x1 struct]   <- like AnnotationValid this shows the length of the data
% 							 AnnotationValid: [1x1 struct]
% 									  ElanFile: [1x1 struct]

elanPlot(elanTS)
% This is only possible with single elan files, not multiple in one struct
ne2 = elanTimeseriesSlice(elanTS,elanTS.tiers.rubbish_annotation,{'1'});
% using pause you can watch plots that show what's happening
ne1 = elanTimeseriesSlice(elanTS,elanTS.tiers.rubbish_annotation,{'1','2'},'all',[5:7],0.5);
% note: you can save each single slice to a file (new dir created with name of your
% original elan .eaf file) using the save_file_prefix (see help elanTimeseriesSlice)
