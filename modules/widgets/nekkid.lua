local addonName, addon = ...

local CONTAINER_BAG_OFFSET = _G.CONTAINER_BAG_OFFSET or 30 -- FrameXML/Constants.lua

-- adjust position of existing tabs
PaperDollSidebarTab3:SetPoint('BOTTOMRIGHT', -60, 0)
PaperDollSidebarTabs.DecorLeft:SetPoint('BOTTOMLEFT', -25, 0)
PaperDollSidebarTabs.DecorRight:SetPoint('BOTTOMRIGHT', 5, 0)

-- create new tab button
local button = addon:CreateButton('Button', addonName .. 'Nekkid', PaperDollSidebarTab3)
button:SetPoint('LEFT', PaperDollSidebarTab3, 'RIGHT', 4, 0)
button:SetSize(33, 35)

-- essentially recreating PaperDollSidebarTabTemplate, which we can't use because it has an OnLoad method
local background = button:CreateTexture(nil, 'BACKGROUND')
background:SetPoint('BOTTOMLEFT', -9, -2)
background:SetSize(50, 43)
background:SetTexture([[Interface\PaperDollInfoFrame\PaperDollSidebarTabs]])
background:SetTexCoord(0.01562500, 0.79687500, 0.61328125, 0.78125000)

local icon = button:CreateTexture(nil, 'ARTWORK')
icon:SetPoint('BOTTOM', 1, 0)
icon:SetSize(27, 30)
icon:SetTexture(132311)
icon:SetTexCoord(0.109375, 0.890625, 0.09375, 0.90625)

local border = button:CreateTexture(nil, 'OVERLAY')
border:SetPoint('BOTTOM')
border:SetSize(34, 19)
border:SetTexture([[Interface\PaperDollInfoFrame\PaperDollSidebarTabs]])
border:SetTexCoord(0.01562500, 0.54687500, 0.11328125, 0.18750000)

local highlight = button:CreateTexture(nil, 'HIGHLIGHT')
highlight:SetPoint('TOPLEFT', 2, -3)
highlight:SetSize(31, 31)
highlight:SetTexture([[Interface\PaperDollInfoFrame\PaperDollSidebarTabs]])
highlight:SetTexCoord(0.01562500, 0.50000000, 0.19531250, 0.31640625)

-- add tooltip because I will forget how to use this
button:SetScript('OnLeave', GameTooltip_Hide)
button:SetScript('OnEnter', function(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:AddLine('Nekkid', 1, 1, 1)

	local setID = C_EquipmentSet.GetEquipmentSetID(addonName .. 'Nekkid')
	if setID then
		GameTooltip:AddLine('|A:NPE_LeftClick:18:18|a Re-equip gear')
	else
		GameTooltip:AddLine('|A:NPE_LeftClick:18:18|a Unequip gear')
		GameTooltip:AddLine('|A:NPE_RightClick:18:18|a Unequip gear and re-equip after resurrection')
	end

	GameTooltip:Show()
end)

local function equipSet()
	local setID = C_EquipmentSet.GetEquipmentSetID(addonName .. 'Nekkid')
	if setID then
		addon:Defer(C_EquipmentSet.UseEquipmentSet, setID)
	end
end

button:SetScript('OnClick', function(self, btn)
	local setID = C_EquipmentSet.GetEquipmentSetID(addonName .. 'Nekkid')
	if setID then
		-- we have an existing equipment set, let's re-equip it
		return equipSet()
	end

	if InCombatLockdown() then
		-- can't unequip anyways
		return
	end

	-- create a temporary equipment set with our current gear
	C_EquipmentSet.CreateEquipmentSet(addonName .. 'Nekkid', 132311)

	-- get free bag slots, we have to do it like this because the free space API
	-- is too slow to react when we put items in the bags
	local emptyBagSpace = {}
	for bagID = Enum.BagIndex.Backpack, Constants.InventoryConstants.NumBagSlots do
		emptyBagSpace[bagID] = C_Container.GetContainerNumFreeSlots(bagID)
	end

	-- unequip everything
	for index = 1, 17 do
		if GetInventoryItemID('player', index) then
			PickupInventoryItem(index)

			for bagID, spaceLeft in next, emptyBagSpace do
				if spaceLeft > 0 then
					if bagID == 0 then
						PutItemInBackpack()
					else
						PutItemInBag(bagID + CONTAINER_BAG_OFFSET) -- enum?
					end

					emptyBagSpace[bagID] = spaceLeft - 1
					break
				end
			end
		end
	end

	-- if we right-clicked the button then re-equip once resurrected
	if btn == 'RightButton' then
		button:RegisterEvent('PLAYER_ALIVE', equipSet)
	end

	-- update tooltip if necessary
	if button:IsMouseOver() then
		button:GetScript('OnEnter')(button)
	end
end)

function addon:EQUIPMENT_SWAP_FINISHED(successful, setID)
	if successful and setID == C_EquipmentSet.GetEquipmentSetID(addonName .. 'Nekkid') then
		-- once equipped, delete the temporary equipment set
		C_EquipmentSet.DeleteEquipmentSet(setID)

		-- if we right-clicked the button then prevent the default behavior
		if button:IsEventRegistered('PLAYER_ALIVE', equipSet) then
			button:UnregisterEvent('PLAYER_ALIVE', equipSet)
		end

		-- update tooltip if necessary
		if button:IsMouseOver() then
			button:GetScript('OnEnter')(button)
		end
	end
end
