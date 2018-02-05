function Discrate
% Reproduction on Bpod of protocol used in the PatonLab, MATCHINGvFix

global BpodSystem
global TaskParameters

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;
if isempty(fieldnames(TaskParameters))
    %% Delays
    TaskParameters.GUI.PreA = 4;
    TaskParameters.GUI.PreB = 1;
    TaskParameters.GUI.PreRandom = false; % random ITI
    TaskParameters.GUIMeta.PreRandom.Style = 'checkbox';
    TaskParameters.GUI.PostA = 1;
    TaskParameters.GUI.PostB = 8;
    TaskParameters.GUI.PostRandom = false; % random ITI
    TaskParameters.GUIMeta.PostRandom.Style = 'checkbox';
    TaskParameters.GUI.LeftA = rand>.5;
    TaskParameters.GUIMeta.LeftA.Style = 'checkbox';
    TaskParameters.GUIPanels.Delays = {'PreA','PreB','PreRandom','PostA','PostB','PostRandom','LeftA'};    
    
    %% General
    TaskParameters.GUI.MaxSessLen = 120; % In minutes
    TaskParameters.GUI.Reverse = true; % At MaxSessLen/2
    TaskParameters.GUIMeta.Reverse.Style = 'checkbox';
    TaskParameters.GUI.Ports_LMR = '123';
    TaskParameters.GUI.rewardAmount = 30;
    TaskParameters.GUI.rewardProb = .5;
    TaskParameters.GUIPanels.General = {'MaxSessLen','Reverse','Ports_LMR','rewardProb','rewardAmount'};
    
    %%
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
end
BpodParameterGUI('init', TaskParameters);

%% Set up PulsePal
load PulsePalParamFeedback.mat
BpodSystem.Data.Custom.PulsePalParamFeedback=PulsePalParamFeedback;
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler';
if ~BpodSystem.EmulatorMode
    ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamFeedback);
end

%% Initialize plots
temp = SessionSummary();
for i = fieldnames(temp)'
    BpodSystem.GUIHandles.(i{1}) = temp.(i{1});
end
clear temp
BpodNotebook('init');
BpodSystem.Data.Custom.ChoiceLeft = [];
BpodSystem.Data.Custom.Rewarded = [];
BpodSystem.Data.Custom.LeftA = [];

%% Main loop
RunSession = true;
% iTrial = 1;

TaskParameters.GUI.LeftA = rand>.5;
tsSessStart = tic;

while toc(tsSessStart) < TaskParameters.GUI.MaxSessLen*60
    if TaskParameters.GUI.Reverse && toc(tsSessStart) > TaskParameters.GUI.MaxSessLen/2
        TaskParameters.GUI.LeftA = ~TaskParameters.GUI.LeftA;
        TaskParameters.GUI.Reverse = false;        
    end
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    
    sma = stateMatrix();
    SendStateMatrix(sma);
    RawEvents = RunStateMatrix;
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        SaveBpodSessionData;
    end
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.BeingUsed == 0
        return
    end
    
    updateCustomDataFields()
    BpodSystem.GUIHandles = SessionSummary(BpodSystem.Data, BpodSystem.GUIHandles);
end
end