local _, addon = ...

function addon:PLAYER_LOGIN()
	-- move and resize the objective tracker
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint('TOPLEFT', 50, -30)
	ObjectiveTrackerFrame:SetHeight(1000)

	-- prevent the tracker from being moved again
	ObjectiveTrackerFrame.ClearAllPoints = nop
	ObjectiveTrackerFrame.SetPoint = nop

	-- prevent the raid manager from overlapping the tracker
	CompactRaidFrameManager:SetFrameStrata('MEDIUM')

	-- move the maw buffs frame
	local mawBuffs = ScenarioBlocksFrame.MawBuffsBlock.Container.List
	mawBuffs:ClearAllPoints()
	mawBuffs:SetPoint('TOPLEFT', mawBuffs:GetParent(), 'TOPRIGHT', 15, 1)

	return true
end
