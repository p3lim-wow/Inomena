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

local function OnDataBrokerEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
	GameTooltip:SetClampedToScreen(true)
	pcall(self.data.OnTooltipShow, GameTooltip)
	GameTooltip:Show()
end

local function CreateDataBrokerButton(LDB, name)
	local data = LDB:GetDataObjectByName(name)
	if(data) then
		local Button = CreateFrame('Button', C.Name .. name .. 'Button', Minimap)
		Button:SetSize(20, 20)
		Button:SetScript('OnClick', data.OnClick)
		Button:SetScript('OnLeave', GameTooltip_Hide)
		Button:SetScript('OnEnter', OnDataBrokerEnter)
		Button:RegisterForClicks('AnyUp')
		Button.data = data

		local Icon = Button:CreateTexture('$parentIcon', 'OVERLAY')
		Icon:SetAllPoints()
		Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		Button:SetNormalTexture(Icon)

		return Button
	end
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

local function OnGarrisonEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
	GameTooltip:SetText(self.title, 1, 1, 1)

	local garrisonType = C_Garrison.GetLandingPageGarrisonType()
	if(garrisonType == LE_GARRISON_TYPE_7_0) then
		GameTooltip:AddLine(' ')

		for _, containerID in next, C_Garrison.GetLooseShipments(garrisonType) do
			local name, texture, cap, ready, _, _, _, timeLeft = C_Garrison.GetLandingPageShipmentInfoByContainerID(containerID)

			local r, g, b
			if(ready > 0) then
				r, g, b = 0, 1, 0
			end

			GameTooltip:AddDoubleLine(ready .. '/' .. cap .. ' - ' .. name, timeLeft, r, g, b)
		end

		for _, data in next, C_Garrison.GetTalentTrees(garrisonType, select(3, UnitClass('player')))[1] do
			if(data.isBeingResearched) then
				GameTooltip:AddDoubleLine('Upgrade: ' .. data.name, SecondsToTime(data.researchTimeRemaining))
			end
		end

		GameTooltip:AddLine(' ')

		local missions = C_Garrison.GetLandingPageItems(garrisonType)
		local completed, ongoing = {}, {}

		for index, data in next, missions do
			if(data.timeLeftSeconds == 0) then
				table.insert(completed, data)
			else
				table.insert(ongoing, data)
			end
		end

		if(#completed > 0) then
			GameTooltip:AddLine('Missions Completed', 1, 1, 1)

			for _, data in next, completed do
				GameTooltip:AddLine('- ' .. data.name, 0, 1, 0)
			end

			GameTooltip:AddLine(' ')
		end

		if(#ongoing > 0) then
			GameTooltip:AddLine('Missions In Progress', 1, 1, 1)

			for _, data in next, ongoing do
				GameTooltip:AddDoubleLine('- ' .. data.name, SecondsToTime(data.timeLeftSeconds))
			end

			GameTooltip:AddLine(' ')
		end

		local available = C_Garrison.GetAvailableMissions(GetPrimaryGarrisonFollowerType(garrisonType))
		if(#available > 0) then
			GameTooltip:AddLine('Missions Available', 1, 1, 1)

			for _, data in next, available do
				if(not data.offerEndTime) then
					-- print(data.name)
				else
					GameTooltip:AddDoubleLine('- ' .. data.name, SecondsToTime(data.offerEndTime - GetTime()))
				end
			end

			GameTooltip:AddLine(' ')
		end
	end

	GameTooltip:AddLine(self.description, 1/2, 1/2, 1/2)
	GameTooltip:Show()
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
	GarrisonLandingPageMinimapButton:SetScript('OnEnter', OnGarrisonEnter)

	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusMinimapButton:SetParent(Minimap)
	QueueStatusMinimapButton:SetPoint('TOPRIGHT')
	QueueStatusMinimapButton:SetHighlightTexture(nil)

	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:SetPoint('TOPLEFT')
	MiniMapMailIcon:SetTexture([[Interface\Minimap\Tracking\Mailbox]])

	MiniMapInstanceDifficulty:UnregisterAllEvents()
	MiniMapInstanceDifficulty:Hide()
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

	SetCVar('rotateMinimap', 0) -- square minimaps look like shit with rotating enabled

	E:UPDATE_INVENTORY_DURABILITY()

	local LDB = LibStub and LibStub('LibDataBroker-1.1', true)
	if(LDB) then
		local BugSack = CreateDataBrokerButton(LDB, 'BugSack')
		if(BugSack) then
			BugSack:SetPoint('BOTTOMRIGHT', -5, 5)
			BugSack:GetNormalTexture():SetTexture([[Interface\CharacterFrame\UI-Player-PlayTimeUnhealthy]])

			if(not string.find(BugSack.data.icon, 'red')) then
				BugSack:SetAlpha(0)
			end

			LDB.RegisterCallback(BugSack, 'LibDataBroker_AttributeChanged_BugSack', function()
				BugSack:SetAlpha(string.find(BugSack.data.icon, 'red') and 1 or 0)
			end)
		end
	end
end

function GetMinimapShape()
	return 'SQUARE'
end

function TimeManager_LoadUI() end
