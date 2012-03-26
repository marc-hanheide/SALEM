function a=getAnnikasQTCTransform
a={};


%%%% straight component human
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
n.qtc_human1='+';
a=[a n];

%%% distancing
n=struct;
n.body_orientation='avert';
n.execution='(diagonally|straight)';
n.qtc_human1='-';
a=[a n];

%%% double cross, zero motion
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


%%%% straight component robot
%%% all '0' cases
n=struct;
n.execution_biron='(pause|orienting|turn)';
n.qtc_robot1='0';
a=[a n];

%%% all approaching cases
n=struct;
n.body_orientation='facing';
n.execution_biron='(straight|drifting|diagonally)';
n.qtc_robot1='+';
a=[a n];


%%% all distaning cases
n=struct;
n.body_orientation='avert';
n.execution_biron='(straight|drifting|diagonally)';
n.qtc_robot1='-';
a=[a n];

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
n.qtc_robot2='-';
a=[a n];


%%% double cross, left motion
n=struct;
n.execution_biron='(straight|drifting|diagonally)';
n.relOrientation='-1';
n.qtc_robot2='+';
a=[a n];


