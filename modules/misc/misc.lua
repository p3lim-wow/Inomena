local E, F = unpack(select(2, ...))

-- Display combat state changes
function E:PLAYER_REGEN_ENABLED()
	UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end

function E:PLAYER_REGEN_DISABLED()
	UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end

-- Set default tab in guild window
function E:ADDON_LOADED(addon)
	if(addon == 'Blizzard_GuildUI') then
		GuildFrame:HookScript('OnShow', function()
			GuildFrameTab2:Click()
		end)
	end
end

-- Auto-deposit reagents
function E:BANKFRAME_OPENED()
	if(not IsShiftKeyDown()) then
		DepositReagentBank()
	end
end

function E:PLAYER_LOGIN()
	-- Move and resize the objective tracker
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint('TOPLEFT', 50, -142)
	ObjectiveTrackerFrame:SetHeight(700)

	ObjectiveTrackerFrame.ClearAllPoints = F.noop
	ObjectiveTrackerFrame.SetPoint = F.noop

	-- Fix frame strata on the raid manager
	CompactRaidFrameManager:SetFrameStrata('MEDIUM')
end

-- Disable queue status sounds
QueueStatusMinimapButton.EyeHighlightAnim:SetScript('OnLoop', nil)

-- Disable error messages
UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')

-- Hide the vehicle seat indicator
VehicleSeatIndicator:UnregisterAllEvents()
VehicleSeatIndicator:Hide()
