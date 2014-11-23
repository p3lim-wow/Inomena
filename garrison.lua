local lastMissionID, numSucceeded, numFailed
local function QueryMissions()
	local missions = C_Garrison.GetCompleteMissions()
	if(#missions > 0) then
		if(not lastMissionID) then
			print('Found', #missions)

			numSucceeded, numFailed = 0, 0
		end

		lastMissionID = missions[1].missionID
		
		C_Timer.After(1/2, function()
			C_Garrison.MarkMissionComplete(lastMissionID)
		end)
	elseif(lastMissionID) then
		GarrisonMissionFrame.MissionTab.MissionList.CompleteDialog:Hide()

		print(numSucceeded, 'missions successful')
		print(numFailed, 'missions failed')

		numSucceeded, numFailed, lastMissionID = nil, nil, nil
	end
end

local Handler = CreateFrame('Frame')
Handler:RegisterEvent('GARRISON_MISSION_NPC_OPENED')
Handler:RegisterEvent('GARRISON_MISSION_COMPLETE_RESPONSE')
Handler:SetScript('OnEvent', function(self, event, ...)
	if(event == 'GARRISON_MISSION_NPC_OPENED') then
		if(IsShiftKeyDown()) then
			self:UnregisterEvent(event)
			self:RegisterEvent('GARRISON_MISSION_NPC_CLOSED')
		else
			QueryMissions()
		end
	elseif(event == 'GARRISON_MISSION_NPC_CLOSED') then
		self:RegisterEvent('GARRISON_MISSION_NPC_OPENED')
	else
		local missionID, canComplete, wasSuccessful = ...
		if(missionID == lastMissionID and canComplete) then
			if(wasSuccessful and C_Garrison.CanOpenMissionChest(missionID)) then
				numSucceeded = numSucceeded + 1
				C_Garrison.MissionBonusRoll(missionID)

				return
			end

			numFailed = numFailed + 1
			C_Timer.After(1/2, QueryMissions)
		end
	end
end)
