local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS -- SharedXML/SharedColorConstants.lua

local TOOLTIP_UNIT_LEVEL = _G.TOOLTIP_UNIT_LEVEL -- globalstring
local TOOLTIP_WILDBATTLEPET_LEVEL_CLASS = _G.TOOLTIP_WILDBATTLEPET_LEVEL_CLASS -- globalstring
local FACTION_ALLIANCE = _G.FACTION_ALLIANCE -- globalstring
local FACTION_HORDE = _G.FACTION_HORDE -- globalstring
local PVP = _G.PVP -- globalstring
local UNKNOWN = _G.UNKNOWN -- globalstring

local DIFFICULTY_COLOR = { -- copied from QuestDifficultyColors to work with enums
	[Enum.RelativeContentDifficulty.Trivial] = CreateColor(0.5, 0.5, 0.5),
	[Enum.RelativeContentDifficulty.Easy] = CreateColor(0.25, 0.75, 0.25),
	[Enum.RelativeContentDifficulty.Fair] = CreateColor(1, 0.82, 0),
	[Enum.RelativeContentDifficulty.Difficult] = CreateColor(1, 0.5, 0.25),
	[Enum.RelativeContentDifficulty.Impossible] = CreateColor(1, 0.1, 0.1),
}

local REACTION_COLOR = {} -- copy of FACTION_BAR_COLORS to use ColorMixin
for key, color in next, FACTION_BAR_COLORS do
	REACTION_COLOR[key] = CreateColor(color.r, color.g, color.b)
end

local TOOLTIP_LEVEL = '^' .. TOOLTIP_UNIT_LEVEL:gsub('%%s', '')
local TOOLTIP_LEVEL_PET = '^' .. TOOLTIP_WILDBATTLEPET_LEVEL_CLASS:gsub(' %%s', '')

local CLASSIFICATION_TEXT = {
	worldboss = ' |cfff01919Boss|r',
	rareelite = '|cffffff00+|r |cff0090ffRare|r',
	rare = ' |cff0090ffRare|r',
	elite = '|cffffff00+|r',
}

local REMOVE_LINES = {
	[FACTION_ALLIANCE] = true,
	[FACTION_HORDE] = true,
	[PVP] = true,
}

-- we can finally after all these years actually prevent text from being added to the tooltip!
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tooltip, data)
	if not tooltip:IsForbidden() and tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		if REMOVE_LINES[data.leftText] then
			return true
		else
			-- hide spec/class tooltip line, which sadly has no line type
			if UnitExists('mouseover') and UnitIsPlayer('mouseover') then
				local unitClass = UnitClass('mouseover')
				if data.leftText:sub(data.leftText:len() - unitClass:len() + 1) == unitClass then
					return true
				end
			end
		end
	end
end)

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitThreat, function(tooltip)
	if not tooltip:IsForbidden() then
		return true -- we never want to see threat on tooltips
	end
end)

local function replaceLine(lineIndex, text, ...)
	if not lineIndex then
		-- ???
		return
	end

	if ... then
		_G['GameTooltipTextLeft' .. lineIndex]:SetText(text:format(...))
	else
		_G['GameTooltipTextLeft' .. lineIndex]:SetText(text)
	end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
	if tooltip:IsForbidden() then
		return
	end

	local unit = data.guid and UnitTokenFromGUID(data.guid)
	if not unit or not UnitIsUnit(unit, 'mouseover') then
		-- replaceLine(1, '|cffff0000%s|r', SPELL_FAILED_BAD_TARGETS)
		return
	elseif UnitIsPlayer(unit) then
		local classColor = C_ClassColor.GetClassColor((UnitClassBase(unit)))
		replaceLine(1, classColor:WrapTextInColorCode(GetUnitName(unit, true)))

		local guildName = GetGuildInfo(unit)
		for _, line in next, data.lines do
			if guildName and line.leftText:match(guildName) then
				-- no type exists for the guild line
				if UnitIsInMyGuild(unit) then
					replaceLine(line.lineIndex, '|cff008cff<%s>|r', guildName)
				else
					replaceLine(line.lineIndex, '|cff00ff19<%s>|r', guildName)
				end
			elseif line.leftText:match(TOOLTIP_LEVEL) then
				-- no type exists for the level line
				local level = UnitEffectiveLevel(unit)
				if UnitIsFriend(unit, 'player') then
					replaceLine(line.lineIndex, '|cffffd000%s|r %s', level, UnitRace(unit))
				else
					local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit)
					local levelLine = DIFFICULTY_COLOR[difficulty]:WrapTextInColorCode(level > 0 and level or '??')
					replaceLine(line.lineIndex, '%s |cffff3300%s|r', levelLine, UnitRace(unit))
				end
			end
		end
	else
		if not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
			replaceLine(1, '|cff999999%s|r', UnitName(unit) or UNKNOWN)
		else
			local reactionColor = REACTION_COLOR[UnitReaction(unit, 'player')]
			if reactionColor then -- can fail?
				replaceLine(1, reactionColor:WrapTextInColorCode(UnitName(unit) or UNKNOWN))
			end
		end

		for _, line in next, data.lines do
			if line.type == Enum.TooltipDataLineType.UnitOwner then
				replaceLine(line.lineIndex, '|cff7f7f7f%s|r', line.leftText)
			elseif line.leftText:match(TOOLTIP_LEVEL) then
				-- no type exists for the level line
				local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit)
				local level = UnitEffectiveLevel(unit)
				local levelLine = DIFFICULTY_COLOR[difficulty]:WrapTextInColorCode(level > 0 and level or '??')
				local rarityText = CLASSIFICATION_TEXT[UnitClassification(unit)] or ''
				local creatureText = UnitCreatureFamily(unit) or UnitCreatureType(unit) or ''
				replaceLine(line.lineIndex, '%s%s %s', levelLine, rarityText, creatureText)
			elseif line.leftText:match(TOOLTIP_LEVEL_PET) then
				replaceLine(line.lineIndex, '|cffffff00%s|r %s', UnitBattlePetLevel(unit), _G['BATTLE_PET_NAME_' .. UnitBattlePetType(unit)])
			elseif line.lineIndex == 2 then
				-- typically the 2nd line is reserved for one of three things: level, owner, or npc title/guild,
				-- so since we've already covered the first two then only title/guild can remain
				replaceLine(line.lineIndex, '|cff8f8f8f%s|r', line.leftText)
			end
		end
	end
end)
