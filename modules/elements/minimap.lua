local E, F, C = unpack(select(2, ...))

local function OnMouseUp(self, button)
	if(button == 'RightButton') then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, 'cursor')
	elseif(button == 'MiddleButton') then
		ToggleCalendar()
	else
		Minimap_OnClick(self)
	end
end

local function OnMouseWheel(self, direction)
	self:SetZoom(self:GetZoom() + (self:GetZoom() == 0 and direction < 0 and 0 or direction))
end

function E:UPDATE_INVENTORY_DURABILITY()
	local alert = 0
	for index in next, INVENTORY_ALERT_STATUS_SLOTS do
		local status = GetInventoryAlertStatus(index)
		if(status > alert) then
			alert = status
		end
	end

	local color = INVENTORY_ALERT_COLORS[alert]
	if(color) then
		Minimap:SetBackdropColor(color.r * 2/3 , color.g * 2/3 , color.b * 2/3 )
	else
		Minimap:SetBackdropColor(0, 0, 0)
	end
end

function E:PLAYER_LOGIN()
	Minimap:ClearAllPoints()
	Minimap:SetParent(UIParent)
	Minimap:SetPoint('TOPRIGHT', -20, -20)
	Minimap:SetBackdrop(C.PlainBackdrop)
	Minimap:SetBackdropColor(0, 0, 0)
	Minimap:SetMaskTexture(C.PlainTexture)
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)
	Minimap:SetScale(0.9)
	Minimap:SetScript('OnMouseUp', OnMouseUp)
	Minimap:SetScript('OnMouseWheel', OnMouseWheel)

	GarrisonLandingPageMinimapButton:ClearAllPoints()
	GarrisonLandingPageMinimapButton:SetParent(Minimap)
	GarrisonLandingPageMinimapButton:SetPoint('BOTTOMLEFT')
	GarrisonLandingPageMinimapButton:SetSize(32, 32)

	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusMinimapButton:SetParent(Minimap)
	QueueStatusMinimapButton:SetPoint('TOPRIGHT')
	QueueStatusMinimapButton:SetHighlightTexture(nil)

	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:SetPoint('TOPLEFT')
	MiniMapMailIcon:SetTexture([[Interface\Minimap\Tracking\Mailbox]])

	MiniMapInstanceDifficulty:Hide()
	MiniMapInstanceDifficulty:UnregisterAllEvents()
	MinimapCluster:EnableMouse(false)
	DurabilityFrame:SetAlpha(0)

	for _, name in next, {
		'GameTimeFrame',
		'MinimapBorder',
		'MinimapBorderTop',
		'MinimapNorthTag',
		'MinimapZoomIn',
		'MinimapZoomOut',
		'MinimapZoneTextButton',
		'MiniMapMailBorder',
		'MiniMapTracking',
		'MiniMapWorldMapButton',
		'QueueStatusMinimapButtonBorder',
		'QueueStatusMinimapButtonGroupSize',
	} do
		local object = _G[name]
		if(object:GetObjectType() == 'Texture') then
			object:SetTexture(nil)
		else
			object.Show = object.Hide
			object:Hide()
		end
	end

	SetCVar('rotateMinimap', 0)

	E:UPDATE_INVENTORY_DURABILITY()

	if(not LibStub) then return end

	local LDB = LibStub('LibDataBroker-1.1', true)
	if(not LDB) then
		return
	end

	local data = LDB:GetDataObjectByName('BugSack')
	if(data) then
		local Bugsack = CreateFrame('Button', nil, Minimap)
		Bugsack:SetPoint('BOTTOMRIGHT', -5, 5)
		Bugsack:SetSize(20, 20)
		Bugsack:SetScript('OnClick', data.OnClick)
		Bugsack:SetScript('OnLeave', GameTooltip_Hide)
		Bugsack:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
			GameTooltip:SetClampedToScreen(true)
			pcall(data.OnTooltipShow, GameTooltip)
			GameTooltip:Show()
		end)

		if(not string.find(data.icon, 'red')) then
			Bugsack:SetAlpha(0)
		end

		local Icon = Bugsack:CreateTexture(nil, 'OVERLAY')
		Icon:SetTexture([[Interface\CharacterFrame\UI-Player-PlayTimeUnhealthy]])
		Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		Icon:SetAllPoints()

		LDB.RegisterCallback(Bugsack, 'LibDataBroker_AttributeChanged_BugSack', function()
			if(string.find(data.icon, 'red')) then
				Bugsack:SetAlpha(1)
			else
				Bugsack:SetAlpha(0)
			end
		end)
	end
end

function GetMinimapShape()
	return 'SQUARE'
end

function TimeManager_LoadUI() end
