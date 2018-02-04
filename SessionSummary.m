function GUIHandles = SessionSummary(Data, GUIHandles)

if nargin < 2 % plot initialized (either beginning of session or post-hoc analysis)
    
    GUIHandles = struct();
    GUIHandles.Figs.MainFig = figure('Position', [200, 200, 300, 300],'name','Outcome plot','numbertitle','off', 'MenuBar', 'none', 'Resize', 'off');
    GUIHandles.Axes.TrialRate.MainHandle = axes('Position', [.15 .15 .7 .7]);
    
    %% Outcome
    axes(GUIHandles.Axes.TrialRate.MainHandle)
    GUIHandles.Axes.TrialRate.TrialRateL = line(GUIHandles.Axes.TrialRate.MainHandle,[0 1],[0 1], 'LineStyle','-','Color',[254,178,76]/255,'Visible','on','linewidth',3);
    GUIHandles.Axes.TrialRate.TrialRateR = line(GUIHandles.Axes.TrialRate.MainHandle,[0 1],[0 1], 'LineStyle','-','Color',[49,163,84]/255,'Visible','on','linewidth',3);
    GUIHandles.Axes.TrialRate.CumRwd = text(1,1,'0mL','verticalalignment','bottom','horizontalalignment','left');
    GUIHandles.Axes.TrialRate.MainHandle.XLabel.String = 'Time (min)';
    GUIHandles.Axes.TrialRate.MainHandle.YLabel.String = 'nTrials';
    GUIHandles.Axes.TrialRate.MainHandle.Title.String = 'Trial rate';
else
    global TaskParameters
end

if nargin > 0
    
    %Cumulative Reward Amount
    set(GUIHandles.Axes.TrialRate.CumRwd, 'position', [0 1], 'string', ...
        [num2str(sum(Data.Custom.Rewarded)*TaskParameters.GUI.rewardAmount/1000) ' mL']);
    
    %% Trial rate
    ndxCho = Data.Custom.ChoiceLeft(:)==1;
    GUIHandles.Axes.TrialRate.TrialRateL.XData = (Data.TrialStartTimestamp(ndxCho)-min(Data.TrialStartTimestamp))/60;
    GUIHandles.Axes.TrialRate.TrialRateL.YData = 1:numel(GUIHandles.Axes.TrialRate.TrialRateL.XData);
    ndxCho = Data.Custom.ChoiceLeft(:)==0;
    GUIHandles.Axes.TrialRate.TrialRateR.XData = (Data.TrialStartTimestamp(ndxCho)-min(Data.TrialStartTimestamp))/60;
    GUIHandles.Axes.TrialRate.TrialRateR.YData = 1:numel(GUIHandles.Axes.TrialRate.TrialRateR.XData);
end
end


