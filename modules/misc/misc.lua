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

-- Auto-accept replacing enchants
function E:REPLACE_ENCHANT()
	if(TradeSkillFrame and TradeSkillFrame:IsShown()) then
		ReplaceEnchant()
		StaticPopup_Hide('REPLACE_ENCHANT')
	end
end

-- Auto-deposit reagents
function E:BANKFRAME_OPENED()
	if(not IsShiftKeyDown()) then
		DepositReagentBank()
	end
end

-- Fix frame strata on the raid manager
function E:PLAYER_LOGIN()
	CompactRaidFrameManager:SetFrameStrata('MEDIUM')
end

-- Disable queue status sounds
QueueStatusMinimapButton.EyeHighlightAnim:SetScript('OnLoop', nil)

-- Disable error messages
UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')

-- Make summon and invite popups escape-proof
StaticPopupDialogs.PARTY_INVITE.hideOnEscape = 0
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = 0

-- Hide the vehicle seat indicator
VehicleSeatIndicator:UnregisterAllEvents()
VehicleSeatIndicator:Hide()
