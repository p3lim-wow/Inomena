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

-- hide buttons around the chat frame
addon:Hide('QuickJoinToastButton')
addon:Hide('ChatFrameChannelButton')
addon:Hide('ChatFrameMenuButton')

-- remove texture around the chat edit box
addon:Hide('ChatFrame1EditBoxMid')
addon:Hide('ChatFrame1EditBoxLeft')
addon:Hide('ChatFrame1EditBoxRight')

for chatIndex = 1, NUM_CHAT_WINDOWS do
	-- hide chat scroll bar and buttons
	addon:Hide(chatFrame, 'buttonFrame')
	addon:Hide(chatFrame, 'ScrollBar')

	-- hide all chat frame regions (background and such)
	for _, region in next, {chatFrame:GetRegions()} do
		addon:Hide(region)
	end

	-- hide all chat tab textures
	for _, region in next, {chatTab:GetRegions()} do
		if region:GetObjectType() == 'Texture' then
			region:SetTexture(nil)
		end
	end
end

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
