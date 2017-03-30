local E, F, C = unpack(select(2, ...))

local SPELL = STAT_CATEGORY_SPELL
local ITEM = HELPFRAME_ITEM_TITLE
local INSTANCE = INSTANCE
local CURRENCY = CURRENCY
local MOUNT = MOUNT

local spellMatch = 'spell:(%d+)'
local itemMatch = 'item:(%d+)'
local currencyMatch = 'currency:(%d+)'

local lineFormat = '%s ' .. ID .. ': |cff93ccea%s|r'
local function AddLine(type, id)
	GameTooltip:AddLine(string.format(lineFormat, type, id))
	GameTooltip:Show()
end

local function AddCurrencyLine(name, texture)
	-- IDs of currencies can only be obtained by looking at the currencies already
	-- obtained by the player, then matching the textures. Good job Blizzard!
	for index = 1, GetCurrencyListSize() do
		local listName, isHeader, isExpanded, _, _, _, listTexture = GetCurrencyListInfo(index)
		if(isHeader and not isExpanded) then
			ExpandCurrencyList(index, 1)
			return AddCurrencyLine(name, texture)
		elseif(listName == name and listTexture == texture) then
			local currencyLink = GetCurrencyListLink(index)
			AddLine(CURRENCY, string.match(currencyLink, currencyMatch))
			return true
		end
	end
end

hooksecurefunc(GameTooltip, 'SetAction', function(self)
	local _, _, spellID = self:GetSpell()
	if(spellID) then
		AddLine(SPELL, spellID)
	else
		local _, itemLink = self:GetItem()
		if(itemLink) then
			AddLine(ITEM, string.match(itemLink, itemMatch))
		end
	end
end)

hooksecurefunc(GameTooltip, 'SetArtifactPowerByID', function(self, powerID)
	local info = C_ArtifactUI.GetPowerInfo(powerID)
	if(info and info.spellID) then
		AddLine(SPELL, info.spellID)
		AddLine(ARTIFACT_POWER, powerID)
	end
end)

hooksecurefunc(GameTooltip, 'SetAuctionItem', function(self, type, index)
	local itemLink = GetAuctionItemLink(type, index)
	if(itemLink) then
		local itemID = string.match(itemLink, itemMatch)
		if(itemID) then
			AddLine(ITEM, itemID)
		end
	end
end)

hooksecurefunc(GameTooltip, 'SetAuctionSellItem', function(self)
	local _, itemLink = self:GetItem()
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetBackpackToken', function(self, index)
	local _, _, _, currencyID = GetBackpackCurrencyInfo(index)
	AddLine(CURRENCY, currencyID)
end)

hooksecurefunc(GameTooltip, 'SetBagItem', function(self, container, slot)
	local itemID = GetContainerItemID(container, slot)
	if(itemID) then
		AddLine(ITEM, itemID)
	end
end)

hooksecurefunc(GameTooltip, 'SetBuybackItem', function(self, slot)
	local itemLink = GetBuybackItemLink(slot)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetCurrencyByID', function(self, currencyID)
	AddLine(CURRENCY, currencyID)
end)

hooksecurefunc(GameTooltip, 'SetCurrencyToken', function(self, listIndex)
	local itemLink = GetCurrencyListLink(listIndex)
	if(itemLink) then
		AddLine(CURRENCY, string.match(itemLink, currencyMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetCurrencyTokenByID', function(self, currencyID)
	AddLine(CURRENCY, currencyID)
end)

hooksecurefunc(GameTooltip, 'SetExistingSocketGem', function(self, slot)
	local itemLink = GetExistingSocketLink(slot)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetGuildBankItem', function(self, tab, slot)
	local itemLink = GetGuildBankItemLink(tab, slot)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetHeirloomByItemID', function(self, itemID)
	AddLine(ITEM, itemID)
end)

hooksecurefunc(GameTooltip, 'SetHyperlink', function(self, link)
	local itemID = string.match(link, itemMatch)
	if(itemID) then
		AddLine(ITEM, itemID)
	else
		local spellID = string.match(link, spellMatch)
		if(spellID) then
			AddLine(SPELL, spellID)
		end
	end
end)

hooksecurefunc(GameTooltip, 'SetInboxItem', function(self, index, slot)
	local itemLink = GetInboxItemLink(index, slot or 1)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetInventoryItem', function(self, unit, slot)
	local itemID = GetInventoryItemID(unit, slot)
	if(itemID) then
		AddLine(ITEM, itemID)
	end
end)

hooksecurefunc(GameTooltip, 'SetItemByID', function(self, itemID)
	AddLine(ITEM, itemID)
end)

hooksecurefunc(GameTooltip, 'SetLFGDungeonReward', function(self, dungeonID, index)
	local itemLink = GetLFGDungeonRewardLink(dungeonID, index)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	else
		if(not AddCurrencyLine(GetLFGDungeonRewardInfo(dungeonID, index))) then
			AddLine(CURRENCY, UNKNOWN) -- currency has not been obtained by player yet
		end
	end
end)

hooksecurefunc(GameTooltip, 'SetLFGDungeonShortageReward', function(self, dungeonID, shortage, index)
	local itemLink = GetLFGDungeonShortageRewardLink(dungeonID, shortage, index)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetLootCurrency', function(self, slot)
	local itemLink = GetLootSlotLink(slot)
	if(itemLink) then
		AddLine(CURRENCY, string.match(itemLink, currencyMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetLootItem', function(self, slot)
	local itemLink = GetLootSlotLink(slot)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetLootRollItem', function(self, index)
	local itemLink = GetLootRollItemLink(index)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetMerchantCostItem', function(self, index, currencyIndex)
	local texture, _, itemLink, name = GetMerchantItemCostItem(index, currencyIndex)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	else
		if(not AddCurrencyLine(name, texture)) then
			AddLine(CURRENCY, UNKNOWN) -- currency has not been obtained by player yet
		end
	end
end)

hooksecurefunc(GameTooltip, 'SetMerchantItem', function(self, slot)
	local itemLink = GetMerchantItemLink(slot)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetMountBySpellID', function(self, spellID)
	AddLine(SPELL, spellID)

	for _, mountID in next, C_MountJournal.GetMountIDs() do
		local _, listSpellID = C_MountJournal.GetMountInfoByID(mountID)
		if(spellID == listSpellID) then
			return AddLine(MOUNT, mountID)
		end
	end
end)

hooksecurefunc(GameTooltip, 'SetPetAction', function(self)
	local _, _, spellID = self:GetSpell()
	if(spellID) then
		AddLine(SPELL, spellID)
	end
end)

hooksecurefunc(GameTooltip, 'SetPvpTalent', function(self, id, isInspect, _, inspectUnit, classID)
	local _, _, _, _, _, spellID = GetPvpTalentInfoByID(id, nil, isInspect, inspectUnit)
	if(spellID) then
		AddLine(SPELL, spellID)
	end
end)

hooksecurefunc(GameTooltip, 'SetQuestCurrency', function(self, type, index)
	if(not AddCurrencyLine(GetQuestCurrencyInfo(type, index))) then
		AddLine(CURRENCY, UNKNOWN) -- currency has not been obtained by player yet
	end
end)

hooksecurefunc(GameTooltip, 'SetQuestItem', function(self, type, index)
	local _, itemID = GetQuestItemInfo(type, index)
	if(itemID) then
		AddLine(ITEM, itemID)
	end
end)

hooksecurefunc(GameTooltip, 'SetQuestLogCurrency', function(self, type, index)
	if(type == 'reward') then
		if(not AddCurrencyLine(GetQuestLogRewardCurrencyInfo(index))) then
			AddLine(CURRENCY, UNKNOWN) -- currency has not been obtained by player yet
		end
	end
end)

hooksecurefunc(GameTooltip, 'SetQuestLogItem', function(self, type, index)
	local itemLink = GetQuestLogItemLink(type, index)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetQuestLogRewardSpell', function(self)
	local _, _, spellID = self:GetSpell()
	if(spellID) then
		AddLine(SPELL, spellID)
	end
end)

hooksecurefunc(GameTooltip, 'SetQuestLogSpecialItem', function(self, questIndex)
	local itemLink = GetQuestLogSpecialItemInfo(questIndex)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetQuestRewardSpell', function(self)
	local _, _, spellID = self:GetSpell()
	if(spellID) then
		AddLine(SPELL, spellID)
	end
end)

hooksecurefunc(GameTooltip, 'SetRecipeReagentItem', function(self, spellID, index)
	local itemLink = C_TradeSkillUI.GetRecipeReagentItemLink(spellID, index)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetRecipeResultItem', function(self, spellID)
	AddLine(SPELL, spellID)
end)

hooksecurefunc(GameTooltip, 'SetSendMailItem', function(self, slot)
	local itemLink = GetSendMailItemLink(slot)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetShapeshift', function(self, index)
	local _, _, _, _, spellID = GetShapeshiftFormInfo(index)
	AddLine(SPELL, spellID)
end)

hooksecurefunc(GameTooltip, 'SetSocketGem', function(self, slot)
	local itemLink = GetNewSocketLink(slot)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetSpellBookItem', function(self, slot, bookType)
	local _, spellID = GetSpellBookItemInfo(slot, bookType)
	if(spellID) then
		AddLine(SPELL, spellID)
	end
end)

hooksecurefunc(GameTooltip, 'SetSpellByID', function(self, spellID)
	AddLine(SPELL, spellID)
end)

hooksecurefunc(GameTooltip, 'SetTalent', function(self, spellID, isInspect, talentGroup)
	AddLine(SPELL, spellID)
end)

hooksecurefunc(GameTooltip, 'SetTotem', function(self, index)
	local _, name = GetTotemInfo(index)
	local _, _, _, _, _, _, spellID = GetSpellInfo(name)
	if(spellID) then
		AddLine(SPELL, spellID)
	end
end)

hooksecurefunc(GameTooltip, 'SetToyByItemID', function(self, itemID)
	AddLine(ITEM, itemID)
end)

hooksecurefunc(GameTooltip, 'SetTradePlayerItem', function(self, slot)
	local itemLink = GetTradePlayerItemLink(slot)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetTradeTargetItem', function(self, slot)
	local itemLink = GetTradeTargetItemLink(slot)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetTrainerService', function(self, index)
	local _, _, spellID = self:GetSpell()
	if(spellID) then
		AddLine(SPELL, spellID)
	end

	local itemLink = GetTrainerServiceItemLink(index)
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetTransmogrifyItem', function(self, slot)
	local itemID = GetInventoryItemID('player', slot)
	if(itemID) then
		AddLine(ITEM, itemID)
	end
end)

hooksecurefunc(GameTooltip, 'SetUpgradeItem', function(self)
	local _, itemLink = self:GetItem()
	if(itemLink) then
		AddLine(ITEM, string.match(itemLink, itemMatch))
	end
end)

hooksecurefunc(GameTooltip, 'SetVoidDepositItem', function(self, slot)
	local itemID = GetVoidTransferDepositInfo(slot)
	if(itemID) then
		AddLine(ITEM, itemID)
	end
end)

hooksecurefunc(GameTooltip, 'SetVoidItem', function(self, page, slot)
	local itemID = GetVoidItemInfo(page, slot)
	if(itemID) then
		AddLine(ITEM, itemID)
	end
end)

hooksecurefunc(GameTooltip, 'SetVoidWithdrawalItem', function(self, slot)
	local itemID = GetVoidTransferWithdrawalInfo(slot)
	if(itemID) then
		AddLine(ITEM, itemID)
	end
end)

hooksecurefunc(GameTooltip, 'SetUnitAura', function(self, unit, index, filter)
	local _, _, _, _, _, _, _, _, _, _, spellID = UnitAura(unit, index, filter)
	if(spellID) then
		AddLine(SPELL, spellID)
	end
end)
