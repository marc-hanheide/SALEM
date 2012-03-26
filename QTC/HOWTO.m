filenm={'VP029.eaf' 'VP030.eaf'};
qtcseq=cell(length(filenm),1);
for i=1:length(filenm)
    elan=elanReadFile(filenm{i});
    [l,ti]=superSegment(elan);
    r=addRelOrientationTier(l);
    res=anno2qtc(r,getAnnikasQTCTransform); 
    [o,qtcseq{i}]=addQTCState(res);
end;

qtcseq{:}
