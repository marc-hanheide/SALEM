function anno=addRelOrientationTier(anno)
s={'left' 'left_middle' 'middle_left' 'middle' 'middle_right' 'right_middle' 'right'};

for (i=1:length(anno))
    anno(i).active.relOrientation=[];
    active=anno(i).active;
    if (~isempty(active.orientation))
        human_ori=strmatch(active.orientation,s,'exact');
        if (~isempty(human_ori) && ~isempty(active.orientation_biron))
            robot_ori=strmatch(active.orientation_biron,s,'exact');
            if (~isempty(robot_ori))
                anno(i).active.relOrientation=num2str(sign(robot_ori-human_ori));
            end;
        end;
    end;    
end;
