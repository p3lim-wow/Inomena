local _, addon = ...

-- the Underlight Angler's trait Underlight Blessing will transform the player into a shark for
-- increased swimming speed, but only if the fishing equipment buff associated with a fishing pole
-- is active on the player, which is only active after the player has fished or recently equipped
-- a fishing pole without entering combat. this module (re)equips the Underlight Angler when the
-- player is swimming in order to activate the trait.

local FISHING_TOOL_INVENTORY_ID = 28
local FISHING_EQUIPMENT_BUFF_ID = 394009
local UNDERLIGHT_ANGLER_ITEM_ID = 133755

local function equip(bagID, slotIndex)
	if not slotIndex then
		-- triggered after checking, we need to find the bagID
		local itemLocation = C_Item.GetItemLocation(bagID) -- it's an itemGUID
		bagID, slotIndex = itemLocation:GetBagAndSlot()
	end

	ClearCursor()
	C_Container.PickupContainerItem(bagID, slotIndex)
	PickupInventoryItem(FISHING_TOOL_INVENTORY_ID)

	return true -- ensure we don't trigger from BAG_UPDATE_DELAYED again
end

local function unequip(bagID, slotIndex)
	-- delay equipping until the bag has received the rod
	addon:DeferEvent('BAG_UPDATE_DELAYED', equip, bagID, slotIndex)

	-- put the rod into the bags
	ClearCursor()
	PickupInventoryItem(FISHING_TOOL_INVENTORY_ID)
	C_Container.PickupContainerItem(bagID, slotIndex)
end

local function check()
	if C_ChallengeMode.IsChallengeModeActive() then
		-- can't change equipment in challenges
		return
	end

	if not IsSwimming() then
		return
	end

	if C_QuestLog.IsOnQuest(76991) then
		-- this quest breaks if we're walking on water, cancel the buff it it's active too
		addon:Defer(C_Spell.CancelSpellByID, FISHING_EQUIPMENT_BUFF_ID)
		return
	end

	local isEquipped = GetInventoryItemID('player', FISHING_TOOL_INVENTORY_ID) == UNDERLIGHT_ANGLER_ITEM_ID
	if isEquipped then
		if C_Secrets.ShouldAurasBeSecret() then
			-- can't check if the buff is active
			return
		end

		if C_UnitAuras.GetPlayerAuraBySpellID(FISHING_EQUIPMENT_BUFF_ID) then
			-- the fishing equipment buff is active, assume everything is ok?
			return
		end
	end

	-- the fishing equipment buff is not active, we need to force it by equipping the rod
	for bagID = Enum.BagIndex.Backpack, Constants.InventoryConstants.NumBagSlots do
		for slotIndex = 1, C_Container.GetContainerNumSlots(bagID) do
			if not isEquipped and C_Container.GetContainerItemID(bagID, slotIndex) == UNDERLIGHT_ANGLER_ITEM_ID then
				-- rod was found in the bags, equip it, passing along itemGUID in case it moves
				local itemLocation = ItemLocation:CreateFromBagAndSlot(bagID, slotIndex)
				addon:Defer(equip, C_Item.GetItemGUID(itemLocation))
				return
			elseif isEquipped and not C_Container.GetContainerItemInfo(bagID, slotIndex) then
				-- rod was equipped, unequp into empty bag slot
				addon:Defer(unequip, bagID, slotIndex)
				return
			end
		end
	end
end

local eventCallbacks = {
	PLAYER_REGEN_ENABLED = check,
	-- we need to delay this event until next frame, as IsSwimming is not true right away
	MOUNT_JOURNAL_USABILITY_CHANGED = GenerateFlatClosure(RunNextFrame, check),
}

local function bank()
	-- check if the player either took the rod out of the bank or put it in
	local itemCount = C_Item.GetItemCount(UNDERLIGHT_ANGLER_ITEM_ID)
	if itemCount > 0 and not addon:IsEventRegistered('PLAYER_REGEN_ENABLED', check) then
		for event, callback in next, eventCallbacks do
			addon:RegisterEvent(event, callback)
		end
	elseif itemCount == 0 and addon:IsEventRegistered('PLAYER_REGEN_ENABLED', check) then
		for event, callback in next, eventCallbacks do
			addon:UnregisterEvent(event, callback)
		end
	end
end

local function quest(_, questID)
	if questID == 41010 then
		-- player turned in the quest Fish Frenzy which awards the rod
		for event, callback in next, eventCallbacks do
			addon:RegisterEvent(event, callback)
		end

		-- we'll need to start monitoring the bank too
		addon:RegisterEvent('BANKFRAME_CLOSED', bank)

		return true -- no need to keep checking
	end
end

function addon:OnLogin()
	if C_Item.GetItemCount(UNDERLIGHT_ANGLER_ITEM_ID) > 0 then
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
end
