% function [newElan,newcsv]=elanTimeseriesSlice(elan,start,stop,linkedFileName,linkedFileColumns,pausedur,save_file_prefix)
%
% An elan struct (read by elanReadFile for instance, or created by
% elanSlice) is sliced (everything else is omitted) according to the given
% arguments:
%
% In contrast to elanSlice, elanTimeseriesSlice slices both timeseries data
% _and_ annotations
%
% arguments:
% ----------
% elan:             struct of data that are to be sliced
% start/stop:       how the data is to be sliced (see below)
% linkedFileName:   (optional) name of linked File to be sliced - default 'all'
%                   note: since elan can't handle more than one linked file until now
%                   (Version 4.0.0) there is normally only one linked File.
%                   (we merged the two files into one file). This means you need to
%                   determine the columns with 'linkedFileColumns'
% linkedFileColumns:(optional) columns to be scliced (you can reduce your data to the
%                   necessary columns with this)
% pausedur:         (optional) duration of the pause between plots/saves (the data
%                   will be plotted only if you give a value >0)
% save_file_prefix: (optional) prefix for the saved slices (a dir is created under the
%                   name <orig_csv>-slices/. Note: only give a string ~='' if you want to
%                   save the single sliced files!
%
%%% examples for slicing possibilities:
% ----------------------------------
%% (1a) slice time interval
% slicedElan=elanSlice(elan, 10, 100);
%
%% (1b) do it with several at once:
%   first slice starts at 10, end at 100,
%   second starts at 200, ends at 400
% slicedElan=elanSlice(elan, [10 200], [100 400]);
%
%% (2a) Slicing with Tiers (taking the given tier as reference and slice
% definition)
% ne=elanSlice(elan,elan.tiers.Blickrichtung_Schokou);
%
%% (2b) slice all annotations of a tier that have a certain value
% ne=(elanSlice(elan,elan.tiers.Blickrichtung_Schokou,'2'));
%% (2c) slice all annotations of a tier that have any of these values
% ne=(elanSlice(elan,elan.tiers.Blickrichtung_Schokou,{'2','3'}));
%
% The second optional parameter can be either 0 or 1. If 1, histogram for
% the duration of the annotations are plotted for those tiers that have a
% variance in their annotation durations.
% ---------------------------------
%
% usage:
% vpen01=elanReadFile('2010-04-22-vpen01.eaf');
% figure(1);elanPlot(vpen01)
% ne = elanTimeseriesSlice(vpen01,vpen01.tiers.Kopfgesten_remus,{'look','look_right'},'all',[],0.1,'look');
% figure(2);elanPlot(ne)
%
% hint: suppress output using evalc
%
% TODO: provide a merged Slicing method elanSlice and elanTimeseriesSlice in
%       one file
%       slice csv-annotation like AnnotationValid to show slicing
%       in plot and calc values
%
% example:
% nodsclices = elanTimeseriesSlice(eaffile,eaffile.tiers.Kopfgesten_romulus,{'nod'},'merged_mt9_data',[11:13],1);
function [newElan,newcsv]=elanTimeseriesSlice(elan,start,stop,linkedFileName,linkedFileColumns,pausedur,save_file_prefix)

% arguments 'save_file_prefix', 'pausedur' , 'linkedFileColums and  'linkedFileName' are optional
if (nargin < 7)
	save_file_prefix = '';
	fprintf('calculate without saving ');
end%if
if (nargin < 6)
	pausedur = 0;
	fprintf('and plotting\n');
else
	fprintf('\n');
end%if
if (nargin < 5)
	linkedFileColumns = [];
end%if
if (nargin < 4)
	linkedFileName = 'all';
end%if
if (pausedur >0)
	% clear the plotting window if we are about to plot
	clf;
end%if

if (isstruct(start))
	% if we are slicing with tiers (example 2) compute start/stop indices of
	% "interesting" annotations and call this function again
	if nargin>=3 % example 2b/2c
		% (for the following see function_handle (@) help text)
		% string-compare all start.value(s) (= all annotation values of this tier)
		% with the given stop argument(s)   (= annotation values to be sliced)
		% max evaluates if at least one strcmp was 1 (= match);
		% cellfun applies function to each cell in cell array (2nd argument: {start.value} = all annotation values)
		cf=[(cellfun(@(x) (max(strcmp(strtrim(x),stop))), {start.value}))];
		% find gets all indices for the cases where strcmp was 'true'
		selectedIndices=find(cf);
		if isempty(selectedIndices)
			error('None of the annotations matches your pattern.');
		end%if
		% create new struct containing indices where annotation matched stop
		% argument
		newElan=elanTimeseriesSlice(elan,[start(selectedIndices).start],[start(selectedIndices).stop],linkedFileName,linkedFileColumns,pausedur,save_file_prefix);
	else % example 2a
		% create new struct containing start/stop indices of the annotations
		newElan=elanTimeseriesSlice(elan,[start.start],[start.stop],linkedFileName,linkedFileColumns,pausedur,save_file_prefix);
	end;%if
else % slicing with timestamps / without tiers (example 1)
	fn=fieldnames(elan.tiers);
	newElan=elan;
	% compute for each tier
	for i=1:length(fn)
		f=fn{i};
		stats.(f).count=length(elan.tiers.(f));
		tier=elan.tiers.(f);
		if (isempty(tier))
			newElan.tiers.(f)=[];
			continue;
		end;
		% check overlap and replace tier with overlaps
		newElan.tiers.(f)=elanComputeOverlap(tier,start,stop);
		%
		%     newElan.tiers.(f)=[];
		%     for j=1:length(start);
		%         inds = find(([elan.tiers.(f).start]>=start(j)) & ([elan.tiers.(f).start]<=stop(j)));
		%         newElan.tiers.(f)=[newElan.tiers.(f) elan.tiers.(f)(inds)];
		%     end;
	end;%for
	for j=1:length(start); % for all slice time intervals (example 1b)
		newElan.tiers.AnnotationValid(j).start=start(j);
		newElan.tiers.AnnotationValid(j).stop=stop(j);
		newElan.tiers.AnnotationValid(j).duration=stop(j)-start(j);
		newElan.tiers.AnnotationValid(j).overlapSeconds=stop(j)-start(j);
		newElan.tiers.AnnotationValid(j).overlapCase=16;
	end;%for
	
	%% %%%%%%%%%%%%%%%%%%%%%%% begin timeseries slicing
	if (isfield(elan,'linkedFiles'))
		%lfIDsall = fieldnames(elan.linkedFiles);
		
		% determine which linked files to slice
		if (iscell(linkedFileName))
			% more than one explicit file name
			i = 0;
			for lfn = 1:length(linkedFileName)
				if (isfield(elan.linkedFiles,linkedFileName(lfn)))
					warning('since elan does not like more than one linked file this is not yet tested!!!');
					i=i+1;
					lfID{i} = linkedFileName{lfn};
				end%if
			end%for
			if (i == 0)
				warning('linkedFileName does not match any existing value... slicing all files')
				lfID = fieldnames(elan.linkedFiles);
			end%if
		elseif (~iscell(linkedFileName))
			% only one file or all
			if (isfield(elan.linkedFiles,linkedFileName))
				lfID{1} = linkedFileName; % cell array with one element
			elseif (strcmp(linkedFileName,'all')) % 'all'
				warning('slicing more than one linked file is not yet tested!');
				lfID = fieldnames(elan.linkedFiles);
			else % 'all'
				warning('linkedFileName does not match any existing value... slicing all files')
				lfID = fieldnames(elan.linkedFiles);
			end%if
		end%if
		
		% compute for each linked file
		for lf = 1:length(lfID)
			% note: since elan can't handle more than one linked file until now
			% (Version 4.0.0) we merged the two files into one file. This means we
			% have to separate the data for slicing again.
			%
			% get filename in order to let user know which file we currently work on
			filename = elan.linkedFiles.(lfID{lf}).name;
			[~, filenamebody]=fileparts(filename);
			% load data from struct
			csvdata = elan.linkedFiles.(lfID{lf}).data;
			fprintf('slicing "%s", ', filename);
			% reduce dimensions of matrix to those given in arguments (normally you
			% need this only if it is a merged csv file (see note above))
			if (~isempty(linkedFileColumns))
				% add timeseries column if not already included
				if (~any(find(linkedFileColumns == 1)))
					linkedFileColumns = [1,linkedFileColumns];
				end%if
				if size(csvdata,2) > length(linkedFileColumns)
					fprintf('reducing data to columns %s, ',num2str(linkedFileColumns));
					csvdata = csvdata(:,linkedFileColumns);
				end
			end%if
			% load data unit from struct
			tsunit = elan.linkedFiles.(lfID{lf}).tsunit;
			% create new matrix with timestamps
			newcsv = NaN(size(csvdata));
			newcsv(:,1) = csvdata(:,1);
			% time conversion
			if (strcmp(tsunit, 's'))
				%convert to milliseconds
				timestamps = csvdata(:,1)*1000;%int32(round(csvdata(:,1)*100)*10);
			elseif (strcmp(tsunit,'ms'))
				timestamps = csvdata(:,1);
			end%if
			
			% slice each time interval
			for j = 1:length(start)
				% compute the start- and stop-point for the interval to be sliced
				% find index of nearest timestamp to our slice timestamp and calc _d_istance
				[dstart,startline] = min(abs(timestamps(:,1)-start(j)*1000));
				[dstop,stopline] = min(abs(timestamps(:,1)-stop(j)*1000));
				% if distance between searched and found timestamp is too great: warn
				if (dstart > 10 || dstop> 10)
					if (stopline-startline == 0)
						fprintf('\n   warning: no data in slice. \n');
						newcsv([startline:stopline]',[2:end]) = NaN;
						continue;
					else
						warning('Distance between searched and found timestamp unusually great. Did timeseries data start before/in/after this annotation? Dstart: %s, Dstop: %s',num2str(dstart),num2str(dstop));
						% NOTE the timestamps given in this warning are
						% in milliseconds while the lines are not in milliseconds!
					end%if
				end%if
				% copy slice data to newcsv
				fprintf('lines %s-%s\n',num2str(startline),num2str(stopline));
				newcsv([startline:stopline]',[2:end]) = csvdata([startline:stopline]',[2:end]);
				
				% optional features plotting and saving
				if (pausedur >0) % if user wants plotting
					plot(csvdata([startline:stopline]',1),csvdata([startline:stopline]',[2:end]));
					drawnow;
					pause(pausedur);
				end%if
				if (~isempty(save_file_prefix)) % if user wants saving
					% save events in single files named with timestamp and annotation name
					% (e.g. 'nod')
					slicedir = strcat(filenamebody,'_slices/');
					% create new dir if necessary
					[~,~,message] = mkdir(slicedir);
					if (~strcmp(message, 'MATLAB:MKDIR:DirectoryExists'))
						error(message);
					end%if
					
					% save this slice to file
					filepath = strcat(slicedir,'slice_',char(lfID),'_',save_file_prefix,'-',int2str(j),'.txt');
					fprintf(' ... saving to %s\n',filepath);
					mysave(csvdata([startline:stopline]',:), filepath, 1);
				end%if
			end%for
			% save all timestamps in seconds format
			newcsv(:,1) = csvdata(:,1);
			% save slice(s) into new struct
			newElan.linkedFiles.(lfID{lf}).data = newcsv;
		end%for
		% now compute statistics over whole sliced csv
		%	if (calcstats == 1)
		%		slicestats = calcstatistics(csvdata([startline:stopline]',:));
		%	end%if
		
		% TODO reduce csv annotations to the true length (same length as csv.data)
		% newElan = reduceCSVannotations(newElan);
	else
		warning('no timeseries data found');
	end%if
end%if start is (not) struct
end%mainfunction

% %% private function reduceCSVannotations(newElan) reduces csv annotations to true length
% % (same length as csv data)
% function newElan = reduceCSVannotations(newElan)
% %TODO correct annotation length
% lfID = fieldnames(newElan.linkedFiles);
% suffixes = {'','_all','_romulus','_remus'};
% % compute for each linked file
% annovalid = newElan.tiers.AnnotationValid;
% for i = 1:length(lfID)
% 	% compute for each suffix
% 	for j = 1:length(suffixes)
% 		possibletiername = strcat(lfID{i},suffixes{j});
% 		if(isfield(newElan.tiers,possibletiername))
% 			% since we already computed the overlap the annotations of these tiers have to
% 			% be overlapping:
% 			%       xxxxxxxxxxxxxxxxxxxxxx
% 			%     999   171717  1717    555555
% 			%    3333333333333333333333333333
% 			% case 17 can be ignnored whereas cases 3,5 and 9 have to be reduced
% 			% compute for each annotation
% 			for k = 1:length(newElan.tiers.(possibletiername))
% 				anno = newElan.tiers.(possibletiername)(k);
% 				if (anno.overlapCase ~= 17) % if it is not an include 
% 					
% 				%else %(nothing to be done)
% 				end%if
% 			end%for
% 		end%if
% 	end%for
% end%for
% end%private function



%% The private function mysave saves data to an .txt file
%
% ARGUMENTS: matrix: can be a vector or a matrix
%            filename: filename to which data should be saved
%            b_overwrite: 0: do not overwrite, 1: overwrite file
% 				 filepath: optionally give filepath
% RETURNS  : -
%
% adierker / 2009-02-16
% USAGE    : mysave(eventmatrix, filepath_2, 0);
function mysave(matrix, filename, b_overwrite, filepath) %#ok<INUSL>
if (nargin<4)
	savename = filename;
else
	savename = strcat(filepath,filename);
end%if

if (b_overwrite)
	save (savename,'-ascii','-double','matrix')
	%dlmwrite(savename,matrix)
elseif (~b_overwrite)
	if (exist(savename,'file'))
		error('File %s already exists, choose b_overwrite=1 if you want to overwrite');
	else
		save (savename,'-ascii','-double','matrix')
	end
else
	warning('third argument for mysave should be 0 or 1');
end%if

%f = fopen (savename,'w');
%fprintf(f, '%f %f \n', [timestamps,matrix(:,column)]');
%fclose(f);
end%privatefunction

% suppress some matlab code warnings for this file (only for use with matlab editor)
%#ok<*WNTAG>
