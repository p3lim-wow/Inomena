local _, addon = ...

-- hide misc crap
addon:Hide('TicketStatusFrame')
addon:Hide('DurabilityFrame')
DurabilityFrame.SetParent = nop -- fuck you edit mode
addon:Hide('VehicleSeatIndicator')
addon:Hide('StanceBar')
addon:Hide('MainMenuBarVehicleLeaveButton')
addon:Hide('MicroMenu')
addon:Hide('BagsBar')

-- order hall bar
addon:HookAddOn('Blizzard_OrderHallUI', function()
	addon:Hide('OrderHallCommandBar')
end)

-- chat frame buttons
addon:Hide('QuickJoinToastButton')
addon:Hide('ChatFrameChannelButton')
addon:Hide('ChatFrameMenuButton')
for index = 1, NUM_CHAT_WINDOWS do
	addon:Hide('ChatFrame' .. index .. 'ButtonFrame')
end

-- minimap
addon:Hide('MinimapCompassTexture')
addon:Hide('MinimapCluster', 'BorderTop')
addon:Hide('MinimapCluster', 'InstanceDifficulty')
addon:Hide('MinimapCluster', 'IndicatorFrame')
-- addon:Hide('MinimapCluster', 'Tracking')
addon:Hide('MinimapCluster', 'ZoneTextButton')
addon:Hide('Minimap', 'ZoomIn')
addon:Hide('Minimap', 'ZoomOut')
addon:Hide('GameTimeFrame')
-- addon:Hide('UIWidgetBelowMinimapContainerFrame')
addon:HookAddOn('Blizzard_TimeManager', function()
	-- hide the clock
	addon:Hide('TimeManagerClockButton')
end)

-- TODO: disable pulse animations
-- ExpansionLandingPageMinimapButton
-- QueueStatusButton

addon:Hide('DebuffFrame')

addon:HookAddOn('Blizzard_WeeklyRewards', function()
	hooksecurefunc(WeeklyRewardsFrame, 'UpdateOverlay', function()
		addon:Hide('WeeklyRewardsFrame', 'Blackout')
		addon:Hide('WeeklyRewardsFrame', 'Overlay')
	end)
end)
