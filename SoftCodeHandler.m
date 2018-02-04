function SoftCodeHandler(softCode)
%soft codes 1-10 reserved for odor delivery
%soft code 11-20 reserved for PulsePal sound delivery

global BpodSystem

if ~BpodSystem.EmulatorMode
    if softCode == 2  % Beep on channel 1+2
        SendCustomPulseTrain(2,0:.001:.3,(ones(1,301)*3));
        SendCustomPulseTrain(1,0:.001:.3,(ones(1,301)*3));
        TriggerPulsePal(1,2);
    end
end
end