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
    %% Economic policy
    TaskParameters.GUI.MaxSessLen = 90; % In minutes
    TaskParameters.GUI.FracForced = 2/3; % fraction of forced choices
    TaskParameters.GUI.Reverse = false; % At MaxSessLen/2
    TaskParameters.GUIMeta.Reverse.Style = 'checkbox';
    TaskParameters.GUI.TrgtCumRwd = 15; % (mL), target cumulative reward, assuming{max_trial_rate,random_policy}
    TaskParameters.GUI.rewardProb = 1;
    TaskParameters.GUI.rewardAmount = TaskParameters.GUI.TrgtCumRwd*1000 / (TaskParameters.GUI.MaxSessLen*60/...
        sum([TaskParameters.GUI.PreA,TaskParameters.GUI.PreB,TaskParameters.GUI.PostA,TaskParameters.GUI.PostB])/2);
    TaskParameters.GUIPanels.Economics = {'MaxSessLen','TrgtCumRwd','FracForced','Reverse','rewardProb','rewardAmount'};
    
    
    %% General
    TaskParameters.GUI.Ports_LMR = '123';
    TaskParameters.GUIPanels.General = {'Ports_LMR'};
    
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
BpodSystem.Data.Custom.Forced = [];
BpodSystem.Data.Custom.Free = [];

%% Main loop
RunSession = true;

while RunSession
    TaskParameters.GUI.rewardAmount = TaskParameters.GUI.TrgtCumRwd*1000 / (TaskParameters.GUI.MaxSessLen*60/...
        sum([TaskParameters.GUI.PreA,TaskParameters.GUI.PreB,TaskParameters.GUI.PostA,TaskParameters.GUI.PostB])/2);
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
    if BpodSystem.Data.TrialStartTimestamp(end) - BpodSystem.Data.TrialStartTimestamp(1) > TaskParameters.GUI.MaxSessLen*60
        RunSession = false;
    elseif TaskParameters.GUI.Reverse && BpodSystem.Data.TrialStartTimestamp(end) - BpodSystem.Data.TrialStartTimestamp(1) > TaskParameters.GUI.MaxSessLen*60/2
        TaskParameters.GUI.LeftA = ~TaskParameters.GUI.LeftA;
        TaskParameters.GUI.Reverse = false;
    end
end
end