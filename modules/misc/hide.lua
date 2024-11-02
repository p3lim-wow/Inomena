local _, addon = ...

-- disable castbar
PlayerCastingBarFrame:SetUnit(nil)
PetCastingBarFrame:SetUnit(nil)
PetCastingBarFrame:UnregisterEvent('UNIT_PET')

-- minimap fluff
Minimap:SetParent(UIParent)
Minimap:ClearAllPoints()
Minimap:SetPoint('TOPRIGHT', -19.9, -19.9) -- stupid pixel offsets
addon:Hide('MinimapCluster') -- because it sucks
addon:Hide('MinimapCompassTexture')
addon:Hide('MinimapCluster', 'BorderTop')
addon:Hide('MinimapCluster', 'InstanceDifficulty')
addon:Hide('MinimapCluster', 'IndicatorFrame')
addon:Hide('MinimapCluster', 'ZoneTextButton')
addon:Hide('Minimap', 'ZoomIn')
addon:Hide('Minimap', 'ZoomOut')
addon:Hide('Minimap', 'ZoomHitArea')
addon:Hide('GameTimeFrame')
addon:HookAddOn('Blizzard_TimeManager', function()
	addon:Hide('TimeManagerClockButton')
end)

-- we have our own buffs and debuffs
addon:Hide('BuffFrame')
addon:Hide('DebuffFrame')
BuffFrame.numHideableBuffs = 0 -- avoid EditMode errors

-- chat frame buttons and such
addon:Hide('QuickJoinToastButton')
addon:Hide('ChatFrameChannelButton')
addon:Hide('ChatFrameMenuButton')
for index = 1, (_G.NUM_CHAT_WINDOWS or 10) do
	addon:Hide('ChatFrame' .. index .. 'ButtonFrame')
	addon:Hide('ChatFrame' .. index, 'ScrollBar')
end
addon:Hide('ChatFrame1EditBoxMid')
addon:Hide('ChatFrame1EditBoxLeft')
addon:Hide('ChatFrame1EditBoxRight')

addon:Hide('MainMenuBarVehicleLeaveButton')
addon:Hide('MicroMenu')
addon:Hide('BagsBar')
addon:Hide('MicroButtonAndBagsBar')
DurabilityFrame:UnregisterAllEvents() -- doesn't taint, just let it be
DurabilityFrame:EnableMouse(false)
DurabilityFrame:SetAlpha(0)

-- misc stuff we hide that isn't covered by EditMode
addon:Hide('TicketStatusFrame')
addon:Hide('VehicleSeatIndicator')
addon:Hide('StanceBar')
addon:HookAddOn('Blizzard_OrderHallUI', function()
	addon:Hide('OrderHallCommandBar')
end)
addon:HookAddOn('Blizzard_WeeklyRewards', function()
	hooksecurefunc(WeeklyRewardsFrame, 'UpdateOverlay', function()
		addon:Hide('WeeklyRewardsFrame', 'Blackout')
		addon:Hide('WeeklyRewardsFrame', 'Overlay')
	end)
end)

-- I keep accidentally clicking the reset buttons
addon:Hide('LFGListFrame', 'SearchPanel', 'FilterButton', 'ResetToDefaults')
for _, frame in next, WorldMapFrame.overlayFrames do
	if frame.ResetButton then
		addon:Hide(frame, 'ResetButton')
	end
end
