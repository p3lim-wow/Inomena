local _, addon = ...

-- style the minimap

-- reparent and reanchor minimap
Minimap:SetParent(UIParent)
Minimap:ClearAllPoints()
Minimap:SetPoint('TOPRIGHT', -20, -20)

-- set size and add backdrop
Minimap:SetSize(200, 200)
addon:AddBackdrop(Minimap)

-- make the minimap square
local MASK = [[Interface\BUTTONS\WHITE8X8]]
Minimap:SetMaskTexture(MASK)
addon:HookAddOn('Blizzard_HybridMinimap', function()
	HybridMinimap.CircleMask:SetTexture(MASK, 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
end)

-- remove blob outlines
Minimap:SetArchBlobRingScalar(0)
Minimap:SetQuestBlobRingScalar(0)

-- hide textures, buttons and widgets
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

-- reanchor tracking so we can use the menu directly
MinimapCluster.Tracking:SetParent(Minimap)
MinimapCluster.Tracking:ClearAllPoints()
MinimapCluster.Tracking.Button:SetMenuAnchor(AnchorUtil.CreateAnchor('TOPRIGHT', Minimap, 'BOTTOMLEFT'))

-- overlay frame to hijack clicks
local clickOverlay = CreateFrame('Frame', nil, Minimap)
clickOverlay:SetAllPoints()
clickOverlay:EnableMouse(true)
clickOverlay:SetPassThroughButtons('LeftButton') -- don't prevent pinging
clickOverlay:SetPropagateMouseMotion(true) -- don't prevent tooltips
clickOverlay:SetScript('OnMouseUp', function(self, button)
	if button == 'MiddleButton' then
		-- open calendar on middle-click
		if InCombatLockdown() then
			addon:Print("Can't open calendar in combat")
		else
			if not C_AddOns.IsAddOnLoaded('Blizzard_Calendar') then
				C_AddOns.LoadAddOn('Blizzard_Calendar')
			end

			if CalendarFrame:IsShown() then
				HideUIPanel(CalendarFrame)
			else
				ShowUIPanel(CalendarFrame)
			end
		end
	elseif button == 'RightButton' then
		-- open tracking menu on right-click
		MinimapCluster.Tracking.Button:OpenMenu()
	end
end)

-- color minimap border based on equipment durability
function addon:UPDATE_INVENTORY_DURABILITY()
	local worstStatus = 0
	for index in next, INVENTORY_ALERT_STATUS_SLOTS do
		local status = GetInventoryAlertStatus(index)
		if status > worstStatus then
			worstStatus = status
		end
	end

	local color = addon.colors.durability[worstStatus]
	if color then
		Minimap:SetBorderColor(color:GetRGB())
	else
		Minimap:SetBorderColor(0, 0, 0)
	end
end
