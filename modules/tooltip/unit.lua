local _, addon = ...

-- colors
local COLOR_TAPPED = CreateColor(3/5, 3/5, 3/5)
local COLOR_GUILD = addon:CreateColor(0, 255, 25)
local COLOR_GUILD_SAME = addon:CreateColor(0, 140, 255)
local COLOR_LEVEL = addon:CreateColor(255, 208, 0)
local COLOR_LEVEL_PET = addon:CreateColor(255, 255, 0)
local COLOR_HOSTILE = addon:CreateColor(255, 51, 0)
local COLOR_OWNER = addon:CreateColor(127, 127, 127)
local COLOR_TITLE = addon:CreateColor(143, 143, 143)
local COLOR_DIFFICULTY = { -- copied from QuestDifficultyColors to work with enums
	[Enum.RelativeContentDifficulty.Trivial] = addon:CreateColor(0.5, 0.5, 0.5),
	[Enum.RelativeContentDifficulty.Easy] = addon:CreateColor(0.25, 0.75, 0.25),
	[Enum.RelativeContentDifficulty.Fair] = addon:CreateColor(1, 0.82, 0),
	[Enum.RelativeContentDifficulty.Difficult] = addon:CreateColor(1, 0.5, 0.25),
	[Enum.RelativeContentDifficulty.Impossible] = addon:CreateColor(1, 0.1, 0.1),
}

-- matching strings
local FACTION_ALLIANCE = _G.FACTION_ALLIANCE -- globalstring
local FACTION_HORDE = _G.FACTION_HORDE -- globalstring
local PVP = _G.PVP -- globalstring
local UNKNOWN = _G.UNKNOWN -- globalstring
local CORPSE = _G.CORPSE -- globalstring
local TOOLTIP_LEVEL = '^' .. _G.TOOLTIP_UNIT_LEVEL:gsub('%%s', '')
local TOOLTIP_LEVEL_PET = '^' .. _G.TOOLTIP_WILDBATTLEPET_LEVEL_CLASS:gsub(' %%s', '')

-- formatting strings
local FORMAT_LEVEL = '%s%s %s'
local FORMAT_LEVEL_PLAYER = '%s %s'
local FORMAT_GUILD = '<%s>'
local FORMAT_CLASSIFICATION = {
	worldboss = ' |cfff01919Boss|r',
	rareelite = '|cffffff00+|r |cff0090ffRare|r',
	rare = ' |cff0090ffRare|r',
	elite = '|cffffff00+|r',
}

-- use PreCall exclusively as PostCall sometimes has a _lot_ of annoying delay,
-- and in PreCall we can straight up disable lines by returning positively
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitName, function(tooltip, data)
	if tooltip:IsForbidden() then
		return
	end

	if not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	local unit = data.unitToken
	if not unit then
		return
	end

	if UnitIsPlayer(unit) then
		local name = GetUnitName(unit, true)

		local transliteratedName = addon:Transliterate(name)
		if transliteratedName ~= name then
			name = '*' .. transliteratedName
		end

		local _, class = UnitClass(unit)
		if class then
			name = addon.colors.class[class]:WrapTextInColorCode(name)
		end

		data.leftText = name
	else
		if not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
			data.leftText = COLOR_TAPPED:WrapTextInColorCode(UnitName(unit) or UNKNOWN)
		else
			local reactionColor = addon.colors.reaction[UnitReaction(unit, 'player')]
			if reactionColor then
				data.leftText = reactionColor:WrapTextInColorCode(UnitName(unit) or UNKNOWN)
			end
		end
	end
end)

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitOwner, function(tooltip, data)
	if tooltip:IsForbidden() then
		return
	end

	if not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	data.leftText = COLOR_OWNER:WrapTextInColorCode(data.leftText)
end)

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitThreat, function(tooltip)
	if not tooltip:IsForbidden() then
		return true
	end
end)

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tooltip, data)
	-- Enum.TooltipDataLineType still doesn't contain a lot of types used in tooltips, or the types
	-- are for some reason restricted, so we'll have to resort to matching and guesswork
	if tooltip:IsForbidden() then
		return
	end

	if not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	if data.leftText == FACTION_HORDE or data.leftText == FACTION_ALLIANCE or data.leftText == PVP then
		return true
	end

	local _, unit = tooltip:GetUnit()
	if not unit then
		return
	end

	if UnitIsPlayer(unit) then
		local class = UnitClass(unit)
		if data.leftText:sub(data.leftText:len() - class:len() + 1) == class then
			return true
		end


		local guild = GetGuildInfo(unit)
		if guild and data.leftText:match(guild) then
			-- TODO: strip away realm
			if UnitIsInMyGuild(unit) then
				data.leftText = COLOR_GUILD_SAME:WrapTextInColorCode(FORMAT_GUILD:format(guild))
			else
				data.leftText = COLOR_GUILD:WrapTextInColorCode(FORMAT_GUILD:format(guild))
			end
		elseif data.leftText:match(TOOLTIP_LEVEL) then
			local level = UnitEffectiveLevel(unit)
			if UnitIsFriend(unit, 'player') then
				local levelText = COLOR_LEVEL:WrapTextInColorCode(level)
				data.leftText = FORMAT_LEVEL_PLAYER:format(levelText, UnitRace(unit))
			else
				local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit)
				local levelText = COLOR_DIFFICULTY[difficulty]:WrapTextInColorCode(level > 0 and level or '??')
				local raceText = COLOR_HOSTILE:WrapTextInColorCode(UnitRace(unit))
				data.leftText = FORMAT_LEVEL_PLAYER:format(levelText, raceText)
			end
		end
	else
		if data.leftText == UnitCreatureFamily(unit) or data.leftText == UnitCreatureType(unit) then
			return true
		elseif data.leftText:match(TOOLTIP_LEVEL) then
			local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit)
			local level = UnitEffectiveLevel(unit)

			local levelText = COLOR_DIFFICULTY[difficulty]:WrapTextInColorCode(level > 0 and level or '??')
			local rarityText = FORMAT_CLASSIFICATION[UnitClassification(unit)] or ''
			local creatureText = UnitCreatureFamily(unit) or UnitCreatureType(unit) or ''
			data.leftText = FORMAT_LEVEL:format(levelText, rarityText, creatureText)
		elseif data.leftText:match(TOOLTIP_LEVEL_PET) then
			local levelText = COLOR_LEVEL_PET:WrapTextInColorCode(UnitBattlePetLevel(unit))
			local familyText = _G['BATTLE_PET_NAME_' .. UnitBattlePetType(unit)]
			data.leftText = FORMAT_LEVEL_PLAYER:format(levelText, familyText)
		elseif data.leftText == CORPSE then
			data.leftText = COLOR_OWNER:WrapTextInColorCode(data.leftText)
		end
	end
end)
