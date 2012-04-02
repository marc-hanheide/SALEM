[ret, found]=system('find hallway_study -name "*eaf"');

[t,rem]=strtok(found);


result=struct([]);
count=0;
while (~isempty(t))
    [study,r]=strtok(t,'/');
    [condition,r]=strtok(r,'/');
    vp=regexprep(strtok(r,'/'),'(.*).eaf','$1');
    
    count=count+1;
    result(count).condition=condition;
    result(count).study=study;
    try
        %read the file:
        elan=elanReadFile(t);
        [l,ti]=superSegment(elan);
        r=addRelOrientationTier(l);
        result(count).vp=vp;
        result(count).qtcAnno=anno2qtc(r,getAnnikasQTCTransform);
        [o,result(count).qtcSeq]=addQTCState(result(count).qtcAnno);
        result(count).parsingOK=true;
        result(count).qtcFailures=length(regexp(reshape(char(result(count).qtcSeq),1,[]),'X'));
    catch exception
        result(count).parsingOK=false;
        result(count).qtcFailures=inf;
        warning('QTC:parseError','VP %s could not be processed: %s\n', vp, exception.message);
    end;
    
    [t,rem]=strtok(rem);
end;


allCorrectIndices=find([result.qtcFailures]==0);
validQTCs={result(allCorrectIndices).qtcSeq}


