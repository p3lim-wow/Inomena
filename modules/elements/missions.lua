local E, F, C = unpack(select(2, ...))

local function Update(self)
	for _, button in next, self.listScroll.buttons do
		local Threats = button.Threats
		if(Threats) then
			Threats:Hide()
		end

		local mission = button.info
		if(mission and not mission.inProgress) then
			local Title = button.Title
			Title:ClearAllPoints()
			Title:SetPoint('TOPLEFT', 160, -14)

			if(not Threats) then
				Threats = CreateFrame('Frame', nil, button)
				Threats:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -14)
				Threats:SetSize(1, 1)

				for index = 1, 3 do
					local Threat = CreateFrame('Frame', nil, Threats, 'GarrisonAbilityCounterWithCheckTemplate')
					Threat.Border:Hide()
					Threat.Away:Hide()
					Threat.Check:SetAtlas('GarrMission_CounterCheck', true)

					local TimeLeft = Threat.TimeLeft
					TimeLeft:ClearAllPoints()
					TimeLeft:SetPoint('CENTER', Threat.Away)
					TimeLeft:SetFontObject(SystemFont_Shadow_Med1_Outline)

					if(index == 1) then
						Threat:SetPoint('LEFT', Threats)
					else
						Threat:SetPoint('LEFT', Threats[index - 1], 'RIGHT', 10, 0)
					end

					Threats[index] = Threat
				end

				button.Threats = Threats
			end

			local _, _, _, _, _, _, _, enemies = C_Garrison.GetMissionInfo(mission.missionID)
			local counterableThreats = GarrisonMission_DetermineCounterableThreats(mission.missionID, LE_FOLLOWER_TYPE_GARRISON_7_0)

			local numThreats = 1
			for _, enemy in next, enemies do
				for mechanicID, mechanic in next, enemy.mechanics do
					local Threat = Threats[numThreats]
					Threat.Icon:SetTexture(mechanic.ability.icon)
					Threat.Check:Hide()
					Threat.TimeLeft:Hide()
					Threat.Working:Hide()
					Threat:Show()

					if(counterableThreats.full[mechanicID] and counterableThreats.full[mechanicID] > 0) then
						counterableThreats.full[mechanicID] = counterableThreats.full[mechanicID] - 1
						Threat.Check:Show()
					elseif(counterableThreats.away[mechanicID] and #counterableThreats.away[mechanicID] > 0) then
						local nextTime = table.remove(counterableThreats.away[mechanicID], 1)
						Threat.TimeLeft:SetText(GarrisonMission_GetDurationStringCompact(nextTime))
						Threat.TimeLeft:Show()
					end

					numThreats = numThreats + 1
				end
			end

			for index = numThreats, #Threats do
				Threats[index]:Hide()
			end

			Threats:Show()
		end
	end
end

function E:ADDON_LOADED(addon)
	if(addon == 'Blizzard_OrderHallUI') then
		hooksecurefunc(OrderHallMissionFrame.MissionTab.MissionList, 'Update', Update)

		return true
	end
end
