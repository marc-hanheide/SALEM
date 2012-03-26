% elanPlot(elan,optionaltitle)
% 
% Plots annotations of elan files tier-sorted on a time line and colors the
% annotations according to their annotation value (equal annotations are
% colored equally)
function elanPlot(elan,optionaltitle)
fn=fieldnames(elan.tiers); %fieldnames = tier names
%gca;
%cla;
gcf;
clf;
set(gcf,'ActivePositionProperty','OuterPosition');
axes('OuterPosition',[.1  .05  .9  .9]);
%f = gcf;
%set(f,'CurrentAxes',gca)
set(gca,'YTickLabel',[],'YTick',[],'YLim',[0.5 length(fn)+0.5]);
set(get(gca,'XLabel'),'String','seconds');
hold on;
minx=max([elan.tiers.AnnotationValid.stop]);% find end point of one annotation
maxx=min([elan.tiers.AnnotationValid.start]);% find start point of one annotation
for i=1:length(fn) %find first annotation on timeline for all tiers
	f=elan.tiers.(fn{i});
	if (~isempty(f))
		minx=min(min([f.start]),minx);
		maxx=max(max([f.stop]),maxx);
	end;
end;

% plot each tier
for i=1:length(fn) % each tier
	f=elan.tiers.(fn{i}); % one tier
	lenf = length(f);
	y=i-0.4;% 'line' in plot where tier will be plotted
	h=0.8; % height for tiers in plot
	numcolor=0;
	if (~isempty(f))
		clear annocolors
		% use of containers.Map (available only in Matlab V2010)
		annocolors = containers.Map('KeyType', 'char', 'ValueType', 'int32');
		for k=1:lenf; %all annotations in tier
			% coloring according to annotations in this tier
			key = char(elan.tiers.(fn{i})(k).value);
			if (isempty(key))
				key = '_empty_';
			end%if
			if (~isKey(annocolors,(key)))
				numcolor=numcolor+1;
				% set color
				annocolors(key) = numcolor;
			end%if
		end%for
		colmap = colormap(jet(numcolor+1));
		
		% plot every annotation in tier
		for j=1:lenf; % all annotations in tier
			x=f(j).start; %start point for annotation
			w=f(j).stop-f(j).start; %width for annotation
			key = char(elan.tiers.(fn{i})(j).value);
			if (isempty(key))
				key = '_empty_';
			end%if
			if (w>0)
				thiscolor  = colmap((annocolors(key)),:);
				thisedgcol = thiscolor; %no edge line
				%thisedgcol = [0.5,0.5,0.5];
				%rectangle('Position',[x y w h], 'EdgeColor',[0.2 0.2 0.2], 'FaceColor',colr,'Curvature',0.2);
				rectangle('Position',[x y w h],  'EdgeColor',thisedgcol, 'FaceColor',thiscolor,'Curvature',0.2);
				%rectangle('Position',[x y w h], 'EdgeColor',thisedgcol, 'FaceColor',thiscolor,'Curvature',0.4);
				if (strcmp(fn{i},'ElanFile'))
					%tiertext = strcat(f(j).value,' : ', numcolor);
					elanfile = strcat(' ',f(j).value);
					text(x,i,elanfile,'Color',[1 1 1],'Interpreter','none');
				end;
				%text(x,y,dec2bin(f(j).overlapCase), 'Rotation',90,'VerticalAlignment','top');
			end;
		end;
	else %empty tier
		% print invisible object for empty tier
		x=0; %start point for annotation
		w=0.001; %width for annotation
		tmp = rectangle('Position',[x y w h],'EdgeColor',[1,1,1]);%, 'FaceColor',thiscolor);
		%alpha(tmp,0);
	end%if
	% text per line (name of tier + number of different annotations)
	tiertext = strcat(fn{i});
	tiertext2 = strcat('#',num2str(numcolor),' (',num2str(lenf),')');
	% Todo: give also number of anntations
	try
		text(minx,i,tiertext,'HorizontalAlignment','right','Interpreter','none','Margin',20,'FontSize',8);
		text(maxx,i,tiertext2,'HorizontalAlignment','left','Interpreter','none','Margin',20,'FontSize',8);
	catch message
		error('No annotations in tier. Did you save your elan file before importing it?');
	end%try
	if (nargin >1)
		title(optionaltitle,'Interpreter','none')
	end
	axis([ 0 maxx -inf inf ]);
	hold off;
end;
