local _, addon = ...

Minimap:SetParent(UIParent)
Minimap:ClearAllPoints()
Minimap:SetPoint('TOPRIGHT', -20, -20)
Minimap:SetMaskTexture(addon.TEXTURE)
Minimap:SetArchBlobRingScalar(0)
Minimap:SetQuestBlobRingScalar(0)
Minimap:SetScript('OnMouseUp', function(self, button)
	if button == 'RightButton' then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, 'cursor')
	elseif button == 'MiddleButton' then
		ToggleCalendar()
	else
		Minimap_OnClick(self)
	end
end)
Minimap:SetScript('OnMouseWheel', function(self, direction)
	self:SetZoom(math.max(self:GetZoom() + direction, 0))
end)

QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint('TOPRIGHT')
QueueStatusMinimapButton:SetHighlightTexture(nil)

local backdrop = Mixin(addon:CreateFrame('MinimapBackdrop', Minimap), addon.mixins.backdrop)
backdrop:SetPoint('TOPRIGHT', 1, 1)
backdrop:SetPoint('BOTTOMLEFT', -1, -1)
backdrop:CreateBackdrop(0)

-- hide some crap
for _, obj in next, {
	'GameTimeFrame',
	'MinimapBorder',
	'MinimapBorderTop',
	'MinimapBackdrop',
	'MinimapCluster',
	'MinimapZoomIn',
	'MinimapZoomOut',
	'MinimapZoneTextButton',
	'MiniMapWorldMapButton',
	'MiniMapMailFrame',
	'MiniMapMailIcon',
	'MiniMapMailBorder',
	'MiniMapInstanceDifficulty',
	'MiniMapTracking',
	'QueueStatusMinimapButtonBorder',
	'QueueStatusMinimapButtonGroupSize',
} do
	addon:Hide(obj)
end

-- prevent the time frame from loading
TimeManager_LoadUI = nop

hooksecurefunc('GarrisonLandingPageMinimapButton_UpdateIcon', function(self)
	self:ClearAllPoints()
	self:SetParent(Minimap)
	self:SetPoint('BOTTOMLEFT')

	-- setting the scale will also mess with the tutorial crap, but that's a fair tradeoff
	-- instead of manually setting the size of the button and all it's child regions
	local garrisonType = C_Garrison.GetLandingPageGarrisonType()
	if garrisonType == Enum.GarrisonType.Type_6_0 then
		self:SetScale(1/2)
	elseif garrisonType == Enum.GarrisonType.Type_7_0 then
		self:SetScale(1/2)
	elseif garrisonType == Enum.GarrisonType.Type_8_0 then
		self:SetScale(3/4)
	elseif garrisonType == Enum.GarrisonType.Type_9_0 then
		self:SetScale(1/2)
	end
end)

GarrisonLandingPageMinimapButton:RegisterForClicks('AnyUp')
GarrisonLandingPageMinimapButton:SetScript('OnClick', function(self, button)
	if button == 'RightButton' and UnitLevel('player') == 60 then
		-- preview the great vault
		LoadAddOn("Blizzard_WeeklyRewards")
		WeeklyRewardsFrame:SetShown(not WeeklyRewardsFrame:IsShown())
	else
		GarrisonLandingPageMinimapButton_OnClick(self, button)
	end
end)

-- color the border based on equipment durability
function addon:UPDATE_INVENTORY_DURABILITY()
	local alert = 0
	for index in next, INVENTORY_ALERT_STATUS_SLOTS do
		local status = GetInventoryAlertStatus(index)
		if status > alert then
			alert = status
		end
	end

	local color = INVENTORY_ALERT_COLORS[alert]
	if color then
		backdrop:SetBackdropBorderColor(color.r * 2/3, color.g * 2/3, color.b * 2/3)
	else
		backdrop:SetBackdropBorderColor(0, 0, 0)
	end
end

addon:HookAddOn('Blizzard_HybridMinimap', function()
	HybridMinimap.MapCanvas:SetMaskTexture(addon.TEXTURE)

	-- the torghast minimap is not solid
	local canvasBackdrop = Mixin(addon:CreateFrame('HybridMinimapBackdrop', HybridMinimap.MapCanvas), addon.mixins.backdrop)
	canvasBackdrop:SetPoint('TOPRIGHT', Minimap, 1, 1)
	canvasBackdrop:SetPoint('BOTTOMLEFT', Minimap, -1, -1)
	canvasBackdrop:CreateBackdrop(1, 0)
end)

function _G.GetMinimapShape()
	-- other addons depend on this, it's a standard
	return 'SQUARE'
end
