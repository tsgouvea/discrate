function updateCustomDataFields
global BpodSystem
global TaskParameters

statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}(BpodSystem.Data.RawData.OriginalStateData{end});

if any(strcmp('PreL',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(end+1) = 1;
elseif any(strcmp('PreR',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(end+1) = 0;
end
BpodSystem.Data.Custom.Rewarded(end+1) = any(strncmp('water_',statesThisTrial,6));
BpodSystem.Data.Custom.LeftA(end+1) = TaskParameters.GUI.LeftA;
BpodSystem.Data.Custom.Forced(end+1) = any(strncmp('forc_',statesThisTrial,5));
BpodSystem.Data.Custom.Free(end+1) = any(strncmp('free_',statesThisTrial,5));
end