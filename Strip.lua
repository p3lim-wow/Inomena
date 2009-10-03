local nekkid
local slots = {1, 3, 5, 6, 7, 8, 9, 10, 16, 17}
local filled = {}

local function equip()
	for k, v in next, filled do
		local bag, slot = string.match(k, '(%d+)-(%d+)')
		if(bag and slot) then
			PickupContainerItem(bag, slot)
			PickupInventoryItem(v)
		end
	end

	table.wipe(filled)
end

local function unequip(index)
	if(GetInventoryItemLink('player', index)) then
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				if(not GetContainerItemLink(bag, slot) and not filled[bag..'-'..slot]) then
					PickupInventoryItem(index)
					PickupContainerItem(bag, slot)

					filled[bag..'-'..slot] = index
					return
				end
			end
		end
	end
end

local function onClick(self)
	if(nekkid) then
		equip()

		self:SetNormalTexture([=[Interface\Buttons\UI-Panel-Button-Disabled]=])
		nekkid = false
	else
		for k, v in next, slots do
			if(GetInventoryItemLink('player', v)) then
				unequip(v)
			end
		end

		self:SetNormalTexture([=[Interface\Buttons\UI-Panel-Button-Up]=])
		nekkid = true
	end
end

local function onLoad(self)
	if(not UnitHasRelicSlot('player')) then
		table.insert(slots, 18)
	end

	self:SetScript('OnShow', nil)
end

local nekkid = CreateFrame('Button', nil, PaperDollFrame, 'UIPanelButtonTemplate')
nekkid:SetPoint('TOP', CharacterTrinket1Slot, 'BOTTOM', 0, -5)
nekkid:SetHeight(27)
nekkid:SetWidth(36)
nekkid:SetNormalTexture([=[Interface\Buttons\UI-Panel-Button-Disabled]=])
nekkid:SetScript('OnClick', onClick)
nekkid:SetScript('OnShow', onLoad)

local undress = CreateFrame('Button', nil, DressUpFrame, 'UIPanelButtonTemplate')
undress:SetPoint('RIGHT', DressUpFrameResetButton, 'LEFT')
undress:SetHeight(22)
undress:SetWidth(80)
undress:SetText('Undress')
undress:SetScript('OnClick', function() DressUpModel:Undress() end)
