% function stats=elanDescriptives(elan)
% 
% calculates descriptive statistics for a (sliced) elan file

function stats=elanDescriptives(elan)
% compute for each tier
fn=fieldnames(elan.tiers);
stats.summedSliceDuration=sum([elan.tiers.AnnotationValid.duration]);
for i=1:length(fn) % for each tier
	f=fn{i};
	stats.(f).count=length(elan.tiers.(f));
	tier=elan.tiers.(f);
	if (isempty(tier))
		stats.(f)=[];
		continue;
	end;
	%% duration stats
	stats.(f).durationsSeconds=[elan.tiers.(f).duration]';
	stats.(f).duration_min=min([elan.tiers.(f).duration]);
	stats.(f).duration_max=max([elan.tiers.(f).duration]);
	stats.(f).duration_median=median([elan.tiers.(f).duration]);
	stats.(f).duration_mean=mean([elan.tiers.(f).duration]);
	stats.(f).duration_sum=sum(([elan.tiers.(f).duration]));
	stats.(f).duration_variance=var([elan.tiers.(f).duration]);
	stats.(f).duration_std_deviation=sqrt(stats.(f).duration_variance);
end;

for i=1:length(fn)% compute for each tier
	f=fn{i};
	tier=elan.tiers.(f);
	if (~isempty(tier))
		%% occupancy stats
		stats.(f).minStart=min([elan.tiers.(f).start]);
		stats.(f).maxStop=max([elan.tiers.(f).stop]);
		%stats.(f).tier.validDuration=sum([elan.tiers.AnnotationValid.duration]);
		%stats.(f).tier.annotatedDuration=sum([elan.tiers.(f).duration]);
		%stats.(f).tier.annotatedPercent=sum([elan.tiers.(f).duration])/sum([elan.tiers.AnnotationValid.duration]);
		stats.(f).sliceOverlapPercentage=sum([elan.tiers.(f).overlapSeconds])/stats.summedSliceDuration;
		stats.(f).sliceOverlapsSeconds=[elan.tiers.(f).overlapSeconds]';
		stats.(f).slice_PercAndCountFullExtends=[nnz(bitand([elan.tiers.(f).overlapCase],2))/length(elan.tiers.(f)), nnz(bitand([elan.tiers.(f).overlapCase],2))];
		stats.(f).slice_PercAndCountEndExtends=[nnz(bitand([elan.tiers.(f).overlapCase],4))/length(elan.tiers.(f)), nnz(bitand([elan.tiers.(f).overlapCase],4))];
		stats.(f).slice_PercAndCountBeginExtends=[nnz(bitand([elan.tiers.(f).overlapCase],8))/length(elan.tiers.(f)), nnz(bitand([elan.tiers.(f).overlapCase],8))];
		stats.(f).slice_PercAndCountIncluded=[nnz(bitand([elan.tiers.(f).overlapCase],16))/length(elan.tiers.(f)), nnz(bitand([elan.tiers.(f).overlapCase],16))];
	end;
end;
