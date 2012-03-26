% function elan = elanAssignTiersWithCSV (elan, tiers, csvid, part)
%
% This function assigns tiers with linkedFiles (or parts of them) given in
% the arguments.
%
% NEEDS    :
% USED BY  :
%
% ARGUMENTS: elan: an elan .eaf file loaded with elanReadFile.m
%            tiers: one or more tiers
%            csvid: id of one linkedFile (timeseries/csv)
%            part: columns of csv file that are assigned to tiers
% RETURNS  : elan: elan .eaf file with assignedTiers struct added            
%
% adierker / 2011-03-03
% USAGE    : [elan] = elanAssignTiersWithCSV(eaffile,{'Kopfgesten_remus','mt9_remus_classification_hg_004'},'csv_1',[2:7]);
% 
% Note: If your assigned pairs are erroneous you have to explicitly 
% reset the assignments to a new value or delete
% them by using the variable browser in your workspace and choose "delete"
% on the assignedTiers struct
function elan = elanAssignTiersWithCSV (elan, tiers, csvid, part)

% check correctness of arguments

% argument one: elan
if (~isfield(elan,'linkedFiles'))
	error('there are no timeseries files linked to your elan file');
end%if

% argument two: tiers
if (~iscell(tiers))
	% if 'tiers' is only single tier create cell with one element
	tiers = {tiers};
end%if	

% argument three: csvid
if (nargin < 3)
	linkedFiles = fieldnames(elan.linkedFiles);
	csvid = linkedFiles{1};
	if (length(linkedFiles)>1)
		warning('please choose _one_ linked File');
	end
elseif (iscell(csvid))
	warning('Elan does not support more than one linked File yet and thus this software toolkit does not support it as well');
elseif (~isfield(elan.linkedFiles,csvid))
	warning('csvid "%s" not found in linked Files',csvid);
end%if

csvlength = size(elan.linkedFiles.(csvid).data,2);
% argument four: part
if (nargin < 4)
	part = [2:csvlength];
elseif (length(part) > csvlength-1)
	error('%s has only columns 2 to %s assign',csvid,num2str(csvlength))
end%if

% which part of the csv shall be assigned?
%partname = strcat('part_',num2str(1));
partsize = strcat('part_',regexprep(num2str(part),' ','_'));

% assign csvids (with parts) with tiernames
% add entries for csvids and all tiernames
for tiernum = 1:length(tiers)
	if (~isfield(elan,'assignedTiers'))
		elan.assignedTiers = struct();
	end%if
	tiername = tiers{tiernum};
	if (isfield(elan.tiers,tiername))
		if (~isfield(elan.assignedTiers,csvid))
			elan.assignedTiers.(csvid) = struct();
		end%if
		elan.assignedTiers.(csvid).(partsize) = tiers;
		%elan.assignedTiers.(csvid).(partname).partsize = num2str(part);
		elan.assignedTiers.(tiername)= struct();
		elan.assignedTiers.(tiername).(csvid) = num2str(part);
		%elan.assignedTiers.(tiername).(partname) = part;
	else
		warning('tiername "%s" not found',tiername); 
	end%if
end%for

end%mainfunction
% suppress some matlab code warnings for this file (only for use with matlab editor)
%#ok<*WNTAG>
