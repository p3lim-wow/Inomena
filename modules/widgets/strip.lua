local addonName, addon = ...

-- add button/tab to CharacterFrame to quickly get freaky

local SET_NAME = addonName .. 'Nude'
local SET_ICON = 132311

-- adjust position of existing tabs
PaperDollSidebarTab3:SetPointsOffset(-60, 0)
PaperDollSidebarTabs.DecorLeft:SetPointsOffset(-25, 0)
PaperDollSidebarTabs.DecorRight:SetPointsOffset(5, 0)

-- create custom tab (mimicing PaperDollSidebarTabTemplate)
local Tab = addon:CreateButton('Button', nil, PaperDollSidebarTab3)
Tab:SetPoint('LEFT', PaperDollSidebarTab3, 'RIGHT', 4, 0)
Tab:SetSize(33, 35)

local Background = Tab:CreateTexture('BACKGROUND')
Background:SetPoint('BOTTOMLEFT', -9, -2)
Background:SetSize(50, 43)
Background:SetTexture([[Interface\PaperDollInfoFrame\PaperDollSidebarTabs]])
Background:SetTexCoord(0.01562500, 0.79687500, 0.61328125, 0.78125000)

local Icon = Tab:CreateTexture('ARTWORK')
Icon:SetPoint('BOTTOM', 1, 0)
Icon:SetSize(27, 30)
Icon:SetTexture(SET_ICON)
Icon:SetTexCoord(0.109375, 0.890625, 0.09375, 0.90625)

local Border = Tab:CreateTexture('OVERLAY')
Border:SetPoint('BOTTOM')
Border:SetSize(34, 19)
Border:SetTexture([[Interface\PaperDollInfoFrame\PaperDollSidebarTabs]])
Border:SetTexCoord(0.01562500, 0.54687500, 0.11328125, 0.18750000)

local Highlight = Tab:CreateTexture('HIGHLIGHT')
Highlight:SetPoint('TOPLEFT', 2, -3)
Highlight:SetSize(31, 31)
Highlight:SetTexture([[Interface\PaperDollInfoFrame\PaperDollSidebarTabs]])
Highlight:SetTexCoord(0.01562500, 0.50000000, 0.19531250, 0.31640625)

-- add a tooltip because I will forget how to use this
Tab:SetScript('OnLeave', addon.HideTooltip)
Tab:SetScript('OnEnter', function(self)
	local tooltip = addon:GetTooltip(self, 'ANCHOR_RIGHT')
	tooltip:AddLine('Strip', 1, 1, 1)

	local setID = C_EquipmentSet.GetEquipmentSetID(SET_NAME)
	if setID then
		tooltip:AddLine('|A:NPE_LeftClick:18:18|a Re-equip gear')
	else
		tooltip:AddLine('|A:NPE_LeftClick:18:18|a Unequip gear')
		tooltip:AddLine('|A:NPE_RightClick:18:18|a Unequip gear and re-equip after resurrection')
	end

	tooltip:Show()
end)

local function equip()
	local setID = C_EquipmentSet.GetEquipmentSetID(SET_NAME)
	if setID then
		addon:Defer(C_EquipmentSet.UseEquipmentSet, setID)
		return true
	end
end

Tab:SetScript('OnClick', function(self, button)
	if equip() then
		return
	end

	if InCombatLockdown() then
		-- can't unequip during combat
		return
	end

	-- create a temporary equipment set with the currently equipped gear
	C_EquipmentSet.CreateEquipmentSet(SET_NAME, SET_ICON)

	-- get free bag slots
	-- we have to do it this way because the existing API is too slow
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
					if bagID == Enum.BagIndex.Backpack then
						PutItemInBackpack()
					else
						PutItemInBag(bagID + CONTAINER_BAG_OFFSET)
					end

					emptyBagSpace[bagID] = spaceLeft - 1
					break
				end
			end
		end
	end

	if button == 'RightButton' then
		-- re-equip upon resurrection
		self:RegisterEvent('PLAYER_ALIVE', equip)
	end

	-- update tooltip if necessary
	if self:IsMouseOver() then
		self:GetScript('OnEnter')(self)
	end
end)

function addon:EQUIPMENT_SWAP_FINISHED(successful, setID)
	if successful and setID == C_EquipmentSet.GetEquipmentSetID(SET_NAME) then
		-- once equipped we delete the temporary set
		C_EquipmentSet.DeleteEquipmentSet(setID)

		-- if we right-clicked the tab then prevent the default behavior
		if Tab:IsEventRegistered('PLAYER_ALIVE', equip) then
			Tab:UnregisterEvent('PLAYER_ALIVE', equip)
		end

		-- update tooltip if necessary
		if Tab:IsMouseOver() then
			Tab:GetScript('OnEnter')(Tab)
		end
	end
end
