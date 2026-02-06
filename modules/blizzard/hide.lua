local _, addon = ...

-- hide misc UI elements

addon:Hide('DurabilityFrame')
addon:Hide('TicketStatusFrame')
addon:Hide('VehicleSeatIndicator')
addon:Hide('BossBanner')
addon:Hide('MainMenuBarVehicleLeaveButton')
addon:Hide('MicroMenuContainer')
addon:Hide('StanceBar')
addon:Hide('BagsBar')

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
