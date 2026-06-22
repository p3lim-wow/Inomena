local _, addon = ...

-- untrack hidden quests stuck as tracked

function addon:PLAYER_LOGIN()
	local numTracked, numQuests = C_QuestLog.GetNumQuestLogEntries()

	if numTracked <= numQuests then
		return
	end

	for index = 1, numTracked do
		local questInfo = C_QuestLog.GetInfo(index)

		if questInfo and questInfo.isHidden then
			C_QuestLog.RemoveQuestWatch(index)
		end
	end
end

-- untrack completed achievements that get stuck as tracked but hidden

function addon:PLAYER_LOGIN()
	local trackingType = Enum.ContentTrackingType.Achievement
	for _, entryID in next, C_ContentTracking.GetTrackedIDs(trackingType) do
		local _, _, _, completed = GetAchievementInfo(entryID)
		if completed then
			pcall(C_ContentTracking.StopTracking, trackingType, entryID) -- it can randomly error out
		end
	end
end

-- untrack traveler's log entries that tend to get stuck

function addon:PLAYER_LOGIN()
	local activities = C_PerksActivities.GetTrackedPerksActivities()
	if activities and activities.trackedIDs then
		for _, id in next, activities.trackedIDs do
			C_PerksActivities.RemoveTrackedPerksActivity(id)
		end
	end
end

-- make sure the dressing room is always maximized

DressUpFrameResetButton:HookScript('OnClick', function()
	if DressUpFrame.MaximizeMinimizeFrame:IsMinimized() then
		DressUpFrame.MaximizeMinimizeFrame:Maximize()
	end
end)
