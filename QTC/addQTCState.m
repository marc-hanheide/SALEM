function [anno, QTCStr]=addQTCState(anno)

lastQTC=['X' 'X' 'X' 'X'];
for i=1:length(anno)
    res=anno(i);
    thisQTC=[res.qtc_human1 res.qtc_robot1 res.qtc_human2 res.qtc_robot2];
    if (any(lastQTC~=thisQTC))
        anno(i).QTC=thisQTC;
        lastQTC=thisQTC;
    else
        anno(i).QTC=[];
    end;
end;
QTCStr=cellstr(reshape([anno.QTC],4,[])');
