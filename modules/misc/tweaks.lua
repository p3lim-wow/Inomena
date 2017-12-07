local E, F, C = unpack(select(2, ...))

-- Display combat state changes
function E:PLAYER_REGEN_ENABLED()
	UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end

function E:PLAYER_REGEN_DISABLED()
	UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end

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

-- Reduce the size of RCLootCouncil's frames
function E:ADDON_LOADED(addon)
	if(addon == 'RCLootCouncil') then
		local RC = LibStub('AceAddon-3.0'):GetAddon('RCLootCouncil', true)
		if(RC) then
			local LootFrame = RC:GetModule('RCLootFrame', true)
			hooksecurefunc(LootFrame, 'GetFrame', function()
				DefaultRCLootFrame:SetScale(0.6)
			end)
		end
	end
end

-- Add movement speed back to the CharacterFrame
if(tonumber((select(2, GetBuildInfo()))) < 25632) then
	function PaperDollFrame_SetMovementSpeed(self, unit)
		if(unit ~= 'player') then
			self:Hide()
			return
		end

		self.wasSwimming = nil
		self.unit = unit
		self:Show()
		MovementSpeed_OnUpdate(self)

		self.onEnterFunc = MovementSpeed_OnEnter
		self:SetScript('OnUpdate', MovementSpeed_OnUpdate)
	end

	CharacterStatsPane.statsFramePool.resetterFunc = function(pool, frame)
		frame:SetScript('OnUpdate', nil)
		frame.onEnterFunc = nil
		frame.UpdateTooltip = nil
		FramePool_HideAndClearAnchors(pool, frame)
	end

	table.insert(PAPERDOLL_STATCATEGORIES[1].stats, {stat = 'MOVESPEED'})
else
	PAPERDOLL_STATCATEGORIES[2][7].hideAt = nil
end

