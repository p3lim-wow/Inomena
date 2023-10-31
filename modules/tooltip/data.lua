local _, addon = ...

local ENCOUNTER_JOURNAL_ITEM = _G.ENCOUNTER_JOURNAL_ITEM -- globalstring
local STAT_CATEGORY_SPELL = _G.STAT_CATEGORY_SPELL -- globalstring
local CURRENCY = _G.CURRENCY -- globalstring
local MOUNT = _G.MOUNT -- globalstring
local MACRO = _G.MACRO -- globalstring
local ID = _G.ID -- globalstring
local UNKNOWN = _G.UNKNOWN -- globalstring
local NAME = _G.NAME -- globalstring

local PREFIXES = {
	item = ENCOUNTER_JOURNAL_ITEM,
	spell = STAT_CATEGORY_SPELL,
	currency = CURRENCY,
	mount = MOUNT,
	npc = 'NPC',
	macro = MACRO,
}

local function addLine(tip, prefix, id, always)
	if always or IsShiftKeyDown() then
		tip:AddLine(string.format('%s %s: |cff93ccea%s|r', PREFIXES[prefix], prefix == 'macro' and NAME or ID, id or UNKNOWN))
	end
end

local tooltip = {}
function tooltip:Item(data)
	addLine(self, 'item', data.id)
end

function tooltip:Spell(data)
	addLine(self, 'spell', data.id)
end

function tooltip:Unit(data)
	if data.guid and not C_PlayerInfo.GUIDIsPlayer(data.guid) then
		addLine(self, 'npc', addon:ExtractIDFromGUID(data.guid))
	end
end

function tooltip:Currency(data)
	addLine(self, 'currency', data.id)
end

function tooltip:Mount(data)
	addLine(self, 'mount', data.id)

	if data.id then
		local _, spellID = C_MountJournal.GetMountInfoByID(data.id)
		addLine(self, 'spell', spellID)
	end
end

function tooltip:PetAction(data)
	for _, line in next, data.lines do
		if line.tooltipID then
			addLine(self, 'spell', line.tooltipID)
			break
		end
	end
end

function tooltip:Macro()
	local button = self:GetOwner()
	if button and button.action then
		local _, macroID = GetActionInfo(button.action)
		if macroID then
			addLine(self, 'macro', (GetMacroInfo(macroID)), true)

			local spellID = GetMacroSpell(macroID)
			if spellID then
				addLine(self, 'spell', spellID)
			end
		end
	end
end

tooltip.Corpse = tooltip.Unit
tooltip.UnitAura = tooltip.Spell
tooltip.Toy = tooltip.Item

for dataType, key in next, Enum.TooltipDataType do
	if tooltip[dataType] then
		TooltipDataProcessor.AddTooltipPostCall(key, tooltip[dataType])
	end
end

-- react to shift key
function addon:MODIFIER_STATE_CHANGED(key)
	if key == 'LSHIFT' or key == 'RSHIFT' and GameTooltip:IsShown() then
		GameTooltip:RefreshData() -- high taint contender
	end
end
