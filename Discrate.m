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
    TaskParameters.GUI.Ports_LMR = '123';
    TaskParameters.GUI.ITI = 0; % (s)
    TaskParameters.GUI.rewardAmount = 30;
    TaskParameters.GUI.rewardProb = .5;
    TaskParameters.GUIPanels.General = {'Ports_LMR','ITI','rewardProb','rewardAmount'};
    
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

%% Main loop
RunSession = true;
% iTrial = 1;

while RunSession
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