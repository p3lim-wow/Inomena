local _, addon = ...

-- add IDs to tooltips while holding down shift

local PREFIXES = {
	item = ENCOUNTER_JOURNAL_ITEM,
	spell = STAT_CATEGORY_SPELL,
	currency = CURRENCY,
	mount = MOUNT,
	macro = MACRO,
	npc = PROF_CRAFTING_ORDER_TYPE_NPC:upper(),
	age = 'Age',
	quest = TRANSMOG_SOURCE_2,
	caster = SPELL_TARGET_CENTER_CASTER:gsub('^%l', string.upper),
}

local SUFFIXES = {
	item = ID,
	spell = ID,
	currency = ID,
	mount = ID,
	macro = NAME,
	npc = ID,
	quest = ID,
}

local LINE_FORMAT = '%s: |cff93ccea%s|r'
local function addTooltipLine(tooltip, kind, value, forced)
	if tooltip:IsForbidden() or not (forced or IsShiftKeyDown()) then
		return
	end

	local prefix = PREFIXES[kind] or ID
	local suffix = SUFFIXES[kind]
	if suffix then
		tooltip:AddLine(LINE_FORMAT:format(prefix .. ' ' .. suffix, value or UNKNOWN))
	else
		tooltip:AddLine(LINE_FORMAT:format(prefix, value or UNKNOWN))
	end

	return true
end

local dataTypeHandlers = {}
function dataTypeHandlers:Item(data)
	addTooltipLine(self, 'item', data.id)
end

function dataTypeHandlers:Spell(data)
	addTooltipLine(self, 'spell', data.id)
end

function dataTypeHandlers:Unit(data)
	if data.guid and not issecretvalue(data.guid) and not C_PlayerInfo.GUIDIsPlayer(data.guid) then
		if addTooltipLine(self, 'npc', C_CreatureInfo.GetCreatureID(data.guid)) then
			-- show spawn time

			-- https://warcraft.wiki.gg/wiki/GUID#Spawn_UIDs
			local _, _, _, _, _, spawnUID = string.split('-', data.guid)
			local serverTime = GetServerTime()
			local spawnEpoch = serverTime - (serverTime % 2^23)
			local spawnEpochOffset = bit.band(tonumber(spawnUID, 16), 0x7fffff)
			local spawnTime = spawnEpoch + spawnEpochOffset

			if spawnTime > serverTime then
				-- if epoch has rolled over since the unit spawned
				spawnTime = spawnTime - ((2^23) - 1)
			end

			addTooltipLine(self, 'age', addon:FormatTime(serverTime - spawnTime))
		end
	end
end

function dataTypeHandlers:Currency(data)
	addTooltipLine(self, 'currency', data.id)
end

function dataTypeHandlers:Mount(data)
	if data.id then
		local _, spellID = C_MountJournal.GetMountInfoByID(data.id)
		if spellID then
			addTooltipLine(self, 'mount', data.id)
			addTooltipLine(self, 'spell', spellID)
		end
	end
end

function dataTypeHandlers:PetAction(data)
	for _, line in next, data.lines do
		if line.tooltipID then
			addTooltipLine(self, 'spell', line.tooltipID)
			break
		end
	end
end

function dataTypeHandlers:Macro(--[[data]])
	-- BUG: data.id is supposedly the macro index, but it's broken for character macros - instead of
	--      being >=120 it's index - 111, for whatever reason, so we have to hack around that
	if self.processingInfo and self.processingInfo.getterName == 'GetAction' then
		local actionID = unpack(self.processingInfo.getterArgs)
		local actionText = C_ActionBar.GetActionText(actionID)
		addTooltipLine(self, 'macro', actionText)

		local _, macroActionID, macroActionType = GetActionInfo(actionID)
		-- BUG?: macroActionType doesn't return 'item' for items
		if macroActionType == 'spell' then
			-- BUG?: we should be able to use GetMacroSpell for this, but it doesn't evalute the
			--       current spell when the macro is conditional
			addTooltipLine(self, macroActionType, macroActionID)
		elseif macroActionType == '' then -- yeah this seems like a bug
			-- macroActionID should be the macro index, but we have to make sure
			if C_Macro.GetMacroName(macroActionID) == actionText then
				local _, itemLink = GetMacroItem(macroActionID)
				if itemLink then
					addTooltipLine(self, 'item', C_Item.GetItemIDForItemInfo(itemLink))
				end
			end
		end
	end
end

dataTypeHandlers.Corpse = dataTypeHandlers.Unit
dataTypeHandlers.Toy = dataTypeHandlers.Item

do
	local getters = {
		GetUnitAura = C_UnitAuras.GetAuraDataByIndex,
		GetUnitAuraByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID,
		GetUnitBuff = C_UnitAuras.GetBuffDataByIndex,
		GetUnitBuffByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID,
		GetUnitDebuff = C_UnitAuras.GetDebuffDataByIndex,
		GetUnitDebuffByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID,
	}

	function dataTypeHandlers:UnitAura(data)
		if data.id then
			-- add caster name to aura tooltips
			local getter = getters[self.processingInfo.getterName]
			if getter then
				local auraInfo = getter(unpack(self.processingInfo.getterArgs))
				if auraInfo and auraInfo.sourceUnit ~= nil then
					local name = UnitName(auraInfo.sourceUnit)

					if not issecretvalue(auraInfo.sourceUnit) then -- sad bear noises
						local _, classToken = UnitClass(auraInfo.sourceUnit)
						if classToken then
							name = C_ClassColor.GetClassColor(classToken):WrapTextInColorCode(name)
						end
					end

					self:AddLine(' ') -- a little spacer here is nice
					addTooltipLine(self, 'caster', name, true)
				end
			end

			addTooltipLine(self, 'spell', data.id)
		end
	end
end

for dataType, key in next, Enum.TooltipDataType do
	if dataTypeHandlers[dataType] then
		TooltipDataProcessor.AddTooltipPostCall(key, dataTypeHandlers[dataType])
	end
end

-- react to shift key when we can
function addon:MODIFIER_STATE_CHANGED(key)
	if not InCombatLockdown() and key == 'LSHIFT' or key == 'RSHIFT' then
		if GameTooltip:IsShown() and not GameTooltip:IsForbidden() then
			if not issecretvalue(GameTooltip:GetUnit()) then
				GameTooltip:RefreshData() -- high taint contender
			end
		else
			-- show this info in our custom tooltip too
			local tooltip = addon:GetTooltip()
			if tooltip:IsShown() and not tooltip:IsForbidden() then
				if not issecretvalue(tooltip:GetUnit()) then
					tooltip:RefreshData() -- high taint contender
				end
			end
		end
	end
end

-- custom handling for quests, as they don't have a tooltip data type
local function questHandler(_, _, questID)
	if questID and addTooltipLine(GameTooltip, 'quest', questID) then
		GameTooltip:Show() -- force re-render
	end
end

addon:RegisterCallback('QuestMapLogTitleButton.OnEnter', questHandler)
addon:RegisterCallback('BonusObjectiveBlock.QuestRewardTooltipShown', questHandler)
addon:RegisterCallback('MapCanvas.QuestPin.OnEnter', questHandler)
addon:RegisterCallback('TaskPOI.TooltipShown', questHandler)
