function sma = stateMatrix()
% global BpodSystem
global TaskParameters
%% Define ports
LeftPort = floor(mod(TaskParameters.GUI.Ports_LMR/100,10));
CenterPort = floor(mod(TaskParameters.GUI.Ports_LMR/10,10));
RightPort = mod(TaskParameters.GUI.Ports_LMR,10);
% ValveTimes  = GetValveTimes(TaskParameters.GUI.rewardAmount, [LeftPort RightPort]);
LeftPortOut = strcat('Port',num2str(LeftPort),'Out');
% CenterPortOut = strcat('Port',num2str(CenterPort),'Out');
RightPortOut = strcat('Port',num2str(RightPort),'Out');
LeftPortIn = strcat('Port',num2str(LeftPort),'In');
CenterPortIn = strcat('Port',num2str(CenterPort),'In');
RightPortIn = strcat('Port',num2str(RightPort),'In');

LeftValve = 2^(LeftPort-1);
RightValve = 2^(RightPort-1);

LeftValveTime  = GetValveTimes(TaskParameters.GUI.rewardAmount, LeftPort);
RightValveTime  = GetValveTimes(TaskParameters.GUI.rewardAmount, RightPort);

if TaskParameters.GUI.LeftA
    PreL = TaskParameters.GUI.PreA;
    PreR = TaskParameters.GUI.PreB;
    PostL = TaskParameters.GUI.PostA;
    PostR = TaskParameters.GUI.PostB;
else
    PreL = TaskParameters.GUI.PreB;
    PreR = TaskParameters.GUI.PreA;
    PostL = TaskParameters.GUI.PostB;
    PostR = TaskParameters.GUI.PostA;
end
if TaskParameters.GUI.PreRandom
    PreL = exprnd(PreL);
    PreR = exprnd(PreR);
end
if TaskParameters.GUI.PostRandom
    PostL = exprnd(PostL);
    PostR = exprnd(PostR);
end

%%
sma = NewStateMatrix();
sma = SetGlobalTimer(sma,1,PreL);
sma = SetGlobalTimer(sma,2,PreR);
sma = AddState(sma, 'Name', 'state_0',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'wait_Cin'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'wait_Cin',...
    'Timer', 0,...
    'StateChangeConditions', {CenterPortIn, 'wait_Sin'},...
    'OutputActions', {strcat('PWM',num2str(CenterPort)),255});
sma = AddState(sma, 'Name', 'wait_Sin',...
    'Timer', 0,...
    'StateChangeConditions', {LeftPortIn,'PreL',RightPortIn,'PreR'},...
    'OutputActions',{strcat('PWM',num2str(LeftPort)),255,strcat('PWM',num2str(RightPort)),255});
assert(TaskParameters.GUI.rewardProb>=0 & TaskParameters.GUI.rewardProb<=1)
%%
sma = AddState(sma, 'Name', 'PreL',...
    'Timer', 0,...
    'StateChangeConditions', {LeftPortOut,'GraceL','GlobalTimer1_End','rewcue_Lin'},...
    'OutputActions', {'GlobalTimerTrig',1});
sma = AddState(sma, 'Name', 'GraceL',...
    'Timer', 0,...
    'StateChangeConditions', {'GlobalTimer1_End','Wait_Lin',LeftPortIn,'GraceLback'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'GraceLback',...
    'Timer', 0,...
    'StateChangeConditions', {'GlobalTimer1_End','rewcue_Lin',LeftPortOut,'GraceL'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'Wait_Lin',...
    'Timer', 0,...
    'StateChangeConditions', {LeftPortIn,'rewarded_Lin'},...
    'OutputActions', {'SoftCode',2,strcat('PWM',num2str(LeftPort)),255});
sma = AddState(sma, 'Name', 'rewcue_Lin',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','rewarded_Lin'},...
    'OutputActions', {'SoftCode',2,strcat('PWM',num2str(LeftPort)),255});

sma = AddState(sma, 'Name', 'PreR',...
    'Timer', 0,...
    'StateChangeConditions', {RightPortOut,'GraceR','GlobalTimer2_End','rewcue_Rin'},...
    'OutputActions', {'GlobalTimerTrig',2});
sma = AddState(sma, 'Name', 'GraceR',...
    'Timer', 0,...
    'StateChangeConditions', {'GlobalTimer2_End','Wait_Rin',RightPortIn,'GraceRback'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'GraceRback',...
    'Timer', 0,...
    'StateChangeConditions', {'GlobalTimer2_End','rewcue_Rin',RightPortOut,'GraceR'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'Wait_Rin',...
    'Timer', 0,...
    'StateChangeConditions', {RightPortIn,'rewarded_Rin'},...
    'OutputActions', {'SoftCode',2,strcat('PWM',num2str(RightPort)),255});
sma = AddState(sma, 'Name', 'rewcue_Rin',...
    'Timer', 0,...
    'StateChangeConditions', {'Tup','rewarded_Rin'},...
    'OutputActions', {'SoftCode',2,strcat('PWM',num2str(RightPort)),255});

if rand < TaskParameters.GUI.rewardProb
    sma = AddState(sma, 'Name', 'rewarded_Lin',...
        'Timer', 0,...
        'StateChangeConditions', {'Tup','water_L'},...
        'OutputActions', {});
    
    sma = AddState(sma, 'Name', 'rewarded_Rin',...
        'Timer', 0,...
        'StateChangeConditions', {'Tup','water_R'},...
        'OutputActions', {});
else
    sma = AddState(sma, 'Name', 'rewarded_Lin',...
        'Timer', 0,...
        'StateChangeConditions', {'Tup','PostL'},...
        'OutputActions', {});
    sma = AddState(sma, 'Name', 'rewarded_Rin',...
        'Timer', 0,...
        'StateChangeConditions', {'Tup','PostR'},...
        'OutputActions', {});
end
sma = AddState(sma, 'Name', 'water_L',...
    'Timer', LeftValveTime,...
    'StateChangeConditions', {'Tup','PostL'},...
    'OutputActions', {'ValveState', LeftValve});
sma = AddState(sma, 'Name', 'PostL',...
    'Timer', PostL,...
    'StateChangeConditions', {'Tup','exit'},...
    'OutputActions', {});
sma = AddState(sma, 'Name', 'water_R',...
    'Timer', RightValveTime,...
    'StateChangeConditions', {'Tup','PostR'},...
    'OutputActions', {'ValveState', RightValve});
sma = AddState(sma, 'Name', 'PostR',...
    'Timer', PostR,...
    'StateChangeConditions', {'Tup','exit'},...
    'OutputActions', {});
end