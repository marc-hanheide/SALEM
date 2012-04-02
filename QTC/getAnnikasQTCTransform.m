function a=getAnnikasQTCTransform
a={};

n=struct;
n.ElanFile='VP';
n.qtc_human1='X';
n.qtc_human2='X';
n.qtc_robot1='X';
n.qtc_robot2='X';
a=[a n];

% as in "Weghe, N.V.D., Kuijpers, B. & Bogaert, P., 2005. A Qualitative
% Trajectory Calculus and the Composition of its Relations. GeoSpatial,
% 281, pp.60-76. Available at: http://www.springerlink.com/index/l8045k1167187x68.pdf [Accessed March 31, 2012]."

%%%% straight component human (C1 component)
% Movement of the first object, with respect to the first perpendicular reference line at time point t (distance constraint):
%  ?: k is moving towards l: ?t1 (t1 < t ? ? t ? (t1 < t ? < t ? d(k|t ?, l|t) > d(k|t, l|t))) ? ?t2 (t < t2 ? ? t + (t < t + < t2 ? d(k|t, l|t) > d(k|t+, l|t)))
%  +: k is moving away from l: ?t1 (t1 < t ? ? t ? (t1 < t ? < t ? d(k|t ?, l|t) < d(k|t, l|t))) ? ?t2 (t < t2 ? ? t + (t < t + < t2 ? d(k|t, l|t) < d(k|t+, l|t)))
%  0: k is stable with respect to l: all other cases
%%% all '0' cases
n=struct;
n.pauses='pause';
n.qtc_human1='0';
a=[a n];

n=struct;
n.execution='sidestep';
n.qtc_human1='0';
a=[a n];

%%% approaching
n=struct;
n.body_orientation='facing';
n.execution='(diagonally|straight)';
n.qtc_human1='-';
a=[a n];

%%% distancing
n=struct;
n.body_orientation='avert';
n.execution='(diagonally|straight)';
n.qtc_human1='+';
a=[a n];

%%% C3. Movement of the first object with respect to the directed reference
%%% line from k to l at time point t (side constraint): 
%%% ?: k is moving to the left side of RLkl: ?t1 (t1 < t ? ? t ? (t1 < t ? < t? k is on the right side of RLkl at t)) ? ?t2 (t < t2 ? ? t + (t < t + < t2?k is on the left side of RLkl at t))
%%% +: k is moving to the right side of RLkl: ?t1 (t1 < t ? ? t ? (t1<t ? < t?k is on the left side of RLkl at t)) ? ?t2 (t < t2 ? ? t + (t<t + < t2?k is on the right side of RLkl at t))
%%% 0: k is moving along RLkl: all other cases

n=struct;
n.velocity='(normal|hesitantly)';
n.relOrientation='0';
n.qtc_human2='0';
a=[a n];

%%% double cross, left motion
n=struct;
n.velocity='(normal|hesitantly)';
n.relOrientation='1';
n.qtc_human2='+';
a=[a n];

%%% double cross, right motion
n=struct;
n.velocity='(normal|hesitantly)';
n.relOrientation='-1';
n.qtc_human2='-';
a=[a n];

%%% special step cases:
n=struct;
n.velocity='(normal|hesitantly)';
n.orientation='left_right';
n.qtc_human2='-';
a=[a n];

n=struct;
n.velocity='(normal|hesitantly)';
n.orientation='right_left';
n.qtc_human2='+';
a=[a n];


%%% double cross, right motion
n=struct;
n.velocity='normal';
n.relOrientation='-1';
n.qtc_human2='-';
a=[a n];


%%% C2. The movement of the second object wrt the second perpendicular
%%% reference line at time point t can be described as in condition 1 (C1)
%%% with k and l interchanged.  
%%% all '0' cases
n=struct;
n.execution_biron='(pause|orienting|turn)';
n.qtc_robot1='0';
a=[a n];

%%% all approaching cases
n=struct;
n.body_orientation='facing';
n.execution_biron='(straight|drifting|diagonally)';
n.qtc_robot1='-';
a=[a n];


%%% all distaning cases
n=struct;
n.body_orientation='avert';
n.execution_biron='(straight|drifting|diagonally)';
n.qtc_robot1='+';
a=[a n];

%%% C4. The movement of the second object wrt the directed reference line
%%% from l to k at time point t can be described as in condition 3 (C3)
%%% with k and l interchanged.  
%%% double cross, zero motion
n=struct;
n.execution_biron='(pause|turn|orienting)';
n.qtc_robot2='0';
a=[a n];

n=struct;
n.relOrientation='0';
n.qtc_robot2='0';
a=[a n];

%%% double cross, left motion
n=struct;
n.execution_biron='(straight|drifting|diagonally)';
n.relOrientation='1';
n.qtc_robot2='+';
a=[a n];


%%% double cross, left motion
n=struct;
n.execution_biron='(straight|drifting|diagonally)';
n.relOrientation='-1';
n.qtc_robot2='-';
a=[a n];


