local _, addon = ...

-- the Underlight Angler's trait Underlight Blessing will transform the player into a shark for
-- increased swimming speed, but only if the fishing equipment buff associated with a fishing pole
-- is active on the player, which is only active after the player has fished or recently equipped
-- a fishing pole without entering combat. this module (re)equips the Underlight Angler when the
-- player is swimming in order to activate the trait.

local FISHING_TOOL_INVENTORY_ID = 28
local FISHING_EQUIPMENT_BUFF_ID = 394009
local UNDERLIGHT_ANGLER_ITEM_ID = 133755
local UNDERLIGHT_ANGLER_SPELL_ID = 188051
local UNDERLIGHT_ANGLER_QUEST_ID = 41010

local function equip()
	C_Item.EquipItemByName(UNDERLIGHT_ANGLER_ITEM_ID)
	return true -- ensure we don't trigger from BAG_UPDATE_DELAYED again
end

local function unequip()
	local bagID, slotIndex = addon:GetEmptyBagSlot()
	if not bagID then
		UIErrorsFrame:AddMessage(ERR_INV_FULL, RED_FONT_COLOR:GetRGB())
		return
	end

	-- delay equipping until the bag has received the rod
	addon:DeferEvent('BAG_UPDATE_DELAYED', equip)

	-- put the rod into the empty bag slot
	-- (I wish we could do this without involving the cursor)
	ClearCursor()
	PickupInventoryItem(FISHING_TOOL_INVENTORY_ID)
	C_Container.PickupContainerItem(bagID, slotIndex)
end

local lastRodGUID
local function check()
	if C_ChallengeMode.IsChallengeModeActive() or UnitIsDeadOrGhost('player') then
		return
	end

	if not IsSwimming() then
		if lastRodGUID then
			-- re-equip previous rod
			local toolLocation = C_Item.GetItemLocation(lastRodGUID)
			if toolLocation and toolLocation:IsValid() and toolLocation:IsBagAndSlot() then
				local bagID, slotIndex = toolLocation:GetBagAndSlot()
				if bagID >= 0 and bagID <= 4 and slotIndex >= 1 then
					ClearCursor()
					C_Container.PickupContainerItem(bagID, slotIndex)
					PickupInventoryItem(FISHING_TOOL_INVENTORY_ID)
				end
			end

			lastRodGUID = nil
		end

		return
	end

	if GetInventoryItemID('player', FISHING_TOOL_INVENTORY_ID) ~= UNDERLIGHT_ANGLER_ITEM_ID then
		local toolLocation = ItemLocation:CreateFromEquipmentSlot(FISHING_TOOL_INVENTORY_ID)
		if toolLocation:IsValid() then
			lastRodGUID = C_Item.GetItemGUID(toolLocation)
		end

		addon:Defer(equip)
	else
		-- check if we have the buff first
		if not C_Secrets.ShouldAurasBeSecret() and C_UnitAuras.GetPlayerAuraBySpellID(FISHING_EQUIPMENT_BUFF_ID) then
			-- the fishing equipment buff is active
			if C_QuestLog.IsOnQuest(76991) then
				-- this quest breaks if we're walking on water, cancel the buff it it's active
				addon:Defer(C_Spell.CancelSpellByID, FISHING_EQUIPMENT_BUFF_ID)
			end
		else
			-- buff is not active, try re-equipping
			addon:Defer(unequip)
		end
	end
end

local eventCallbacks = {
	PLAYER_REGEN_ENABLED = check,
	-- we need to delay these events until next frame, as IsSwimming is not true right away
	PLAYER_IS_GLIDING_CHANGED = GenerateFlatClosure(RunNextFrame, check),
	MOUNT_JOURNAL_USABILITY_CHANGED = GenerateFlatClosure(RunNextFrame, check),
}

local function cast(_, _, _, spellID)
	if InCombatLockdown() or issecretvalue(spellID) then
		return
	elseif spellID == UNDERLIGHT_ANGLER_SPELL_ID then
		-- the hidden cast for the rod failed, as the fishing equipment buff is not active,
		-- unequip the rod and re-equip it to activate the fishing equipment buff
		addon:Defer(unequip)
	end
end

local function bank()
	-- check if the player either took the rod out of the bank or put it in
	local itemCount = C_Item.GetItemCount(UNDERLIGHT_ANGLER_ITEM_ID)
	if itemCount > 0 and not addon:IsEventRegistered('PLAYER_REGEN_ENABLED', check) then
		addon:RegisterUnitEvent('UNIT_SPELLCAST_FAILED_QUIET', 'player', cast)
		for event, callback in next, eventCallbacks do
			addon:RegisterEvent(event, callback)
		end
	elseif itemCount == 0 and addon:IsEventRegistered('PLAYER_REGEN_ENABLED', check) then
		addon:UnregisterUnitEvent('UNIT_SPELLCAST_FAILED_QUIET', 'player', cast)
		for event, callback in next, eventCallbacks do
			addon:UnregisterEvent(event, callback)
		end
	end
end

local function quest(_, questID)
	if questID == UNDERLIGHT_ANGLER_QUEST_ID then
		-- player turned in the quest Fish Frenzy which awards the rod
		addon:RegisterUnitEvent('UNIT_SPELLCAST_FAILED_QUIET', 'player', cast)
		for event, callback in next, eventCallbacks do
			addon:RegisterEvent(event, callback)
		end

		-- we'll need to start monitoring the bank too
		addon:RegisterEvent('BANKFRAME_CLOSED', bank)

		return true -- no need to keep checking
	end
end

local function inventory()
	if C_Item.GetItemCount(UNDERLIGHT_ANGLER_ITEM_ID) > 0 then
		addon:RegisterUnitEvent('UNIT_SPELLCAST_FAILED_QUIET', 'player', cast)
		for event, callback in next, eventCallbacks do
			addon:RegisterEvent(event, callback)
		end

		-- monitor the bank too in case the player puts the rod in there
		addon:RegisterEvent('BANKFRAME_CLOSED', bank)
	else
		local itemCountWithBank = C_Item.GetItemCount(UNDERLIGHT_ANGLER_ITEM_ID, true)
		if itemCountWithBank > 0 then
			-- check when the player takes the rod out of the bank
			addon:RegisterEvent('BANKFRAME_CLOSED', bank)
		else
			-- wait until the player completes the quest
			addon:RegisterEvent('QUEST_TURNED_IN', quest)
		end
	end

	return true
end

addon:RegisterEvent('PLAYER_ENTERING_WORLD', function(_, isInitialLogin)
	if isInitialLogin then
		addon:RegisterUnitEvent('UNIT_INVENTORY_CHANGED', 'player', inventory)
	else
		return inventory()
	end
end)
