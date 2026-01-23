local _, addon = ...

-- hide misc UI elements

addon:Hide('DurabilityFrame')
addon:Hide('TicketStatusFrame')
addon:Hide('VehicleSeatIndicator')
addon:Hide('BossBanner')

-- hide extra widgets
addon:Hide('MainMenuBarVehicleLeaveButton')
addon:Hide('MicroMenuContainer')
addon:Hide('StanceBar')
addon:Hide('BagsBar')

-- hide bloat on the minimap
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
addon:Hide('ExpansionLandingPageMinimapButton')

-- we create our own buffs (modules\widgets\buffs.lua)
addon:Hide('BuffFrame')
CVarCallbackRegistry:UnregisterCallback('consolidateBuffs', BuffFrame)
CVarCallbackRegistry:UnregisterCallback('collapseExpandBuffs', BuffFrame)

-- we create our own debuffs (modules\units\player.lua)
addon:Hide('DebuffFrame')

addon:HookAddOn('Blizzard_OrderHallUI', function()
	addon:Hide('OrderHallCommandBar')
end)

addon:HookAddOn('Blizzard_WeeklyRewards', function()
	-- this feels like an ad blocker
	hooksecurefunc(WeeklyRewardsFrame, 'UpdateOverlay', function()
		addon:Hide('WeeklyRewardsFrame', 'Blackout')
		addon:Hide('WeeklyRewardsFrame', 'Overlay')
	end)
end)

-- disable clock on the minimap
addon:HookAddOn('Blizzard_TimeManager', function()
	addon:Hide('TimeManagerClockButton')
end)
