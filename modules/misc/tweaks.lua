local E, F, C = unpack(select(2, ...))

local whitelistedHeads = {
	[69294] = true, -- 'Look out!' in Suramar scenario
}

local function OnTalkingHeadShow(self)
	if(not InomenaSeenHeads) then
		InomenaSeenHeads = {}
	end

	local _, _, voiceOverID = C_TalkingHead.GetCurrentLineInfo()
	if(whitelistedHeads[voiceOverID]) then
		return
	end

	if(InomenaSeenHeads[voiceOverID]) then
		TalkingHeadFrame_CloseImmediately()
	elseif(voiceOverID) then
		InomenaSeenHeads[voiceOverID] = true
	end
end

function E:ADDON_LOADED(addon)
	if(addon == 'Blizzard_GuildUI') then
		-- Set default tab in guild window
		GuildFrame:HookScript('OnShow', function()
			GuildFrameTab2:Click()
		end)
	elseif(addon == 'Blizzard_OrderHallUI') then
		-- Hide the Class Hall bar
		OrderHallCommandBar:Hide()
		OrderHallCommandBar.Show = F.noop
	elseif(addon == 'Blizzard_TalkingHeadUI') then
		-- Only show the talking head once
		TalkingHeadFrame:HookScript('OnShow', OnTalkingHeadShow)
	end
end

function E:PLAYER_LOGIN()
	-- Move and resize the objective tracker
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint('TOPLEFT', 50, -30)
	ObjectiveTrackerFrame:SetHeight(1000)

	ObjectiveTrackerFrame.ClearAllPoints = F.noop
	ObjectiveTrackerFrame.SetPoint = F.noop

	-- Fix frame strata on the raid manager
	CompactRaidFrameManager:SetFrameStrata('MEDIUM')
end

-- Disable queue status sounds
QueueStatusMinimapButton.EyeHighlightAnim:SetScript('OnLoop', nil)

-- Hide the vehicle seat indicator
VehicleSeatIndicator:UnregisterAllEvents()
VehicleSeatIndicator:Hide()

-- Add movement speed back to the CharacterFrame
hooksecurefunc('PaperDollFrame_SetMovementSpeed', function(self)
	self:Show()
end)

table.insert(PAPERDOLL_STATCATEGORIES[1].stats, {stat = 'MOVESPEED'})
