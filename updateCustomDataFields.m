function updateCustomDataFields
global BpodSystem

statesThisTrial = BpodSystem.Data.RawData.OriginalStateNamesByNumber{end}(BpodSystem.Data.RawData.OriginalStateData{end});

if any(strcmp('PreL',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(end+1) = 1;
elseif any(strcmp('PreR',statesThisTrial))
    BpodSystem.Data.Custom.ChoiceLeft(end+1) = 0;
end
BpodSystem.Data.Custom.Rewarded(end+1) = any(strncmp('water_',statesThisTrial,6));

end