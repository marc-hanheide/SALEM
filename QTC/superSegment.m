function [out,tierIndex]=superSegment(elan)
tierIndex=fieldnames(elan.tiers);
segments=[];
iSegments=0;
for (i=1:length(tierIndex)) 
    iSegments=iSegments+1;
    tier=elan.tiers.(tierIndex{i});
    if (isempty(tier))
        continue;
    end;
    start=[tier.start];
    stop=[tier.stop];
    startBlock=[repmat(i,1,length(start)); repmat(1,1,length(start)); start; 1:length(start)];
    stopBlock=[repmat(i,1,length(start)); repmat(0,1,length(start)); stop; 1:length(stop)];
    
    segments=[segments;startBlock';stopBlock'];
end
ordered=sortrows(segments,[3 2 1]);
[au, survivingIds,assignedIds]=almostUnique(ordered(:,3));
activeAnno=cell(length(tierIndex),1);
for (i=1:length(survivingIds))
    matchingIds=find(assignedIds==i);
    segment(i).annotations=ordered(matchingIds,:);
    segment(i).time=ordered(survivingIds(i),3);
    segment(i).startingIds=find(segment(i).annotations(:,2)==1);
    segment(i).stoppingIds=find(segment(i).annotations(:,2)==0);
    segment(i).startingTiers=segment(i).annotations(segment(i).startingIds,1);
    segment(i).stoppingTiers=segment(i).annotations(segment(i).stoppingIds,1);
    segment(i).startingAnno=segment(i).annotations(segment(i).startingIds,4);
    segment(i).stoppingAnno=segment(i).annotations(segment(i).stoppingIds,4);
    for (j=1:length(segment(i).stoppingTiers))
        activeAnno(segment(i).stoppingTiers(j))={[]};
    end;
    for (j=1:length(segment(i).startingTiers))
        ti=segment(i).startingTiers(j);
        tier=elan.tiers.(tierIndex{ti});
        anno=tier(segment(i).startingAnno(j));
        activeAnno(ti)={anno.value};
    end;
    segment(i).active=cell2struct(activeAnno,tierIndex,1);
end;
out=segment;