local _, addon = ...

-- replace bags by dragging to the bag icon
local function putInBag(self)
	local id = ContainerIDToInventoryID(self:GetParent():GetID())
	if CursorHasItem() and not PutItemInBag(id) then
		ClearCursor()
	end
end

local function pickUpBag(self)
	local id = ContainerIDToInventoryID(self:GetParent():GetID())
	if not CursorHasItem() then
		PickupBagFromSlot(id)
	end
end

local function onMouseUp(self, button)
	if button == 'LeftButton' then
		local id = ContainerIDToInventoryID(self:GetParent():GetID())
		if CursorHasItem() and not PutItemInBag(id) then
			ClearCursor()
		elseif not CursorHasItem() then
			PickupBagFromSlot(id)
		end
	else
		self:GetParent():OnMouseDown()
	end
end

local function onEnter(self)
	local parent = self:GetParent()
	local id = ContainerIDToInventoryID(parent:GetID())
	GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
	GameTooltip:SetInventoryItem('player', id)
	GameTooltip:Show()
	parent.Highlight:Show()
end

local function onLeave(self)
	local parent = self:GetParent()
	parent:GetScript('Onleave')(parent)
end

for index = 2, 12 do
	local parent = _G['ContainerFrame' .. index .. 'PortraitButton']
	local button = addon:CreateButton('BagButton' .. index, parent)
	button:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	button:RegisterForDrag('LeftButton')
	button:SetAllPoints()
	button:SetScript('OnEnter', onEnter)
	button:SetScript('OnLeave', onLeave)
	button:SetScript('OnMouseUp', onMouseUp)
	button:SetScript('OnReceiveDrag', putInBag)
	button:SetScript('OnDragStart', pickUpBag)
end
