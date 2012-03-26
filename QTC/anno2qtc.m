function anno=anno2qtc(anno, matchingAnnos)

valid=ones(length(anno),1);
for i=1:length(anno)
    if (isempty(anno(i).startingIds))
        valid(i)=0;
        continue;
    end;
    fn=fieldnames(anno(i).active);
    
    for k=1:length(matchingAnnos)
        matches=[];
        for j=1:length(fn)
            queryField=fn{j};
            if(isfield(matchingAnnos{k},queryField))
                if (matchField(anno(i).active.(queryField), matchingAnnos{k}.(queryField)))
                    %fprintf('i=%d, k=%d: matches %s: %s matches %s\n', i, k,queryField, anno(i).active.(queryField), matchingAnnos{k}.(queryField));
                    matches=k;
                else
                    matches=[];
                    %fprintf('i=%d, k=%d: doesn''t match %s: %s not matches %s\n', i,k, queryField, anno(i).active.(queryField), matchingAnnos{k}.(queryField));
                    break;
                end;
            end;
        end;
        if (~isempty(matches))
            qtc_fn=fieldnames(matchingAnnos{matches});
            for n=1:length(qtc_fn)
                if (strfind(qtc_fn{n},'qtc')==1)
                    %fprintf('  => %s\n', qtc_fn{n});
                    anno(i).(qtc_fn{n})=matchingAnnos{matches}.(qtc_fn{n});
                end;
            end;
        end;
    end;
    
end;

anno=anno(find(valid));

function res=matchField(a,b)
    
    if (isempty(a) || isempty(b))
        res=false;
    else
        
        res=~isempty(regexp(a,b, 'match'));
        %a,b,res
    end;
    
        


