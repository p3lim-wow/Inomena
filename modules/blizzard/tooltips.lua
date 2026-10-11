local _, addon = ...

-- skin tooltips

local REALM_SUFFIX = addon.colors.tooltip.greyed:WrapTextInColorCode(' (%s)')
local FORMAT_NAME_REALM = '%s' .. REALM_SUFFIX
local FORMAT_GUILD = '<%s>'
local FORMAT_LEVEL = '%s%s %s'
local FORMAT_LEVEL_PLAYER = '%s %s'
local FORMAT_CLASSIFICATION = {
	worldboss = addon.colors.classification.worldboss:WrapTextInColorCode(' Boss'),
	rare = addon.colors.classification.rare:WrapTextInColorCode(' Rare'),
	elite = addon.colors.classification.elite:WrapTextInColorCode('+'),
}
FORMAT_CLASSIFICATION.rareelite = FORMAT_CLASSIFICATION.elite .. FORMAT_CLASSIFICATION.rare

-- color unit name
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitName, function(tooltip, data)
	if tooltip:IsForbidden() or not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	local _, _, unitGUID = tooltip:GetUnit() -- is this safe now?
	if not unitGUID then
		return
	end

	local color = data.leftColor
	local _, classToken = GetPlayerInfoByGUID(unitGUID)
	if classToken ~= nil then
		-- this works for players, but not for player NPCs (like in follower dungeons),
		-- which is a tradeoff I'm fine with as it's only an issue for raid/party frames
		color = C_ClassColor.GetClassColor(classToken)
	else
		local unit = UnitTokenFromGUID(unitGUID)
		if not issecretvalue(unit) and unit ~= nil then
			if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit) then
				_, classToken = UnitClass(unit)
				if classToken ~= nil then
					color = C_ClassColor.GetClassColor(classToken)
				end
			elseif UnitIsMinion(unit) then
				color = addon:CreateColor(UnitSelectionColor(unit, true))
			end
		end
	end

	if issecretvalue(color) then
		-- the color can randomly be secret, most likely from Blizzard not sanitizing correctly
		return
	end

	local r, g, b = color:GetRGB()
	tooltip.StatusBar:SetStatusBarColor(r, g, b)

	local name, realm = addon:UnitNameFromGUID(unitGUID)
	if realm ~= nil then
		tooltip:AddLine(FORMAT_NAME_REALM:format(name, realm), r, g, b)
	elseif name ~= nil then
		tooltip:AddLine(name, r, g, b)
	else
		tooltip:AddLine(data.leftText, r, g, b)
	end

	return true -- we're replacing the line, so prevent the original one from rendering
end)

-- color unit ownership
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitOwner, function(tooltip, data)
	if tooltip:IsForbidden() or not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	tooltip:AddLine(data.leftText, addon.colors.tooltip.greyed:GetRGB())
	return true
end)

-- remove some lines
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitThreat, function(tooltip)
	if not tooltip:IsForbidden() then
		return true
	end
end)

-- amalgamation of misc lines we want to remove or customize
local MATCH_TOOLTIP_LEVEL = '^' .. TOOLTIP_UNIT_LEVEL:gsub('%%s', '')
local MATCH_TOOLTIP_LEVEL_PET = '^' .. TOOLTIP_WILDBATTLEPET_LEVEL_CLASS:gsub(' %%s', '')
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tooltip, data)
	if tooltip:IsForbidden() or not tooltip:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	if issecretvalue(data.leftText) then
		-- apparently not all lines are secret
		return
	elseif data.leftText == PVP then
		-- WTB Enum.TooltipDataLineType.PvP
		return true
	elseif data.leftText == FACTION_HORDE or data.leftText == FACTION_ALLIANCE then
		-- WTB Enum.TooltipDataLineType.UnitFaction
		return true
	elseif data.leftText == CORPSE then
		-- WTB Enum.TooltipDataLineType.Corpse
		tooltip:AddLine(data.leftText, addon.colors.tooltip.greyed:GetRGB())
		return true
	elseif data.leftText:match('A:friendslist%-recentallies%-yellow') then
		-- WTB Enum.TooltipDataLineType.RecentAllies
		return true
	end

	local _, unit = tooltip:GetUnit()
	if unit == nil or issecretvalue(unit) then
		return
	end

	if UnitIsPlayer(unit) then
		local guildName = GetGuildInfo(unit)
		if guildName and data.leftText:match(guildName) then
			-- WTB Enum.TooltipDataLineType.Guild
			local color
			if UnitIsInMyGuild(unit) then
				color = addon.colors.tooltip.guildie
			else
				color = addon.colors.tooltip.guild
			end

			tooltip:AddLine(FORMAT_GUILD:format(guildName), color:GetRGB())

			return true
		end

		local localizedClass = UnitClass(unit)
		if data.leftText:sub(data.leftText:len() - localizedClass:len() + 1) == localizedClass then
			-- WTB Enum.TooltipDataLineType.UnitClass
			return true
		end
	elseif UnitIsBattlePet(unit) and data.leftText == UnitName(unit) then
		local color = addon.colors.reaction[UnitReaction(unit, 'player')]
		if color then
			-- WTB Enum.TooltipDataLineType.BattlePetName
			tooltip:AddLine(data.leftText, color:GetRGB())
			return true
		end
	end

	if data.leftText == UnitCreatureFamily(unit) or data.leftText == UnitCreatureType(unit) then
		-- WTB Enum.TooltipDataLineType.UnitType
		return true
	elseif data.leftText:match(MATCH_TOOLTIP_LEVEL) then
		-- WTB Enum.TooltipDataLineType.UnitLevel
		local level = UnitEffectiveLevel(unit)
		local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit)

		if UnitIsPlayer(unit) then
			if UnitIsFriend(unit, 'player') then
				local levelText = addon.colors.tooltip.level:WrapTextInColorCode(level > 0 and level or '??')
				tooltip:AddLine(FORMAT_LEVEL_PLAYER:format(levelText, UnitRace(unit)), 1, 1, 1)
				return true
			else
				local levelText = addon.colors.difficulty[difficulty]:WrapTextInColorCode(level > 0 and level or '??')
				local raceText = addon.colors.tooltip.hostile:WrapTextInColorCode(UnitRace(unit))
				tooltip:AddLine(FORMAT_LEVEL_PLAYER:format(levelText, raceText))
				return true
			end
		else
			local levelText = addon.colors.difficulty[difficulty]:WrapTextInColorCode(level > 0 and level or '??')
			local rarityText = FORMAT_CLASSIFICATION[UnitClassification(unit)] or ''
			local creatureText = UnitCreatureFamily(unit) or UnitCreatureType(unit) or ''
			tooltip:AddLine(FORMAT_LEVEL:format(levelText, rarityText, creatureText), 1, 1, 1)
			return true
		end
	elseif data.leftText:match(MATCH_TOOLTIP_LEVEL_PET) then
		-- WTB Enum.TooltipDataLineType.CompanionLevel
		local levelText = addon.colors.tooltip.levelpet:WrapTextInColorCode(UnitBattlePetLevel(unit))
		local familyText = _G['BATTLE_PET_NAME_' .. UnitBattlePetType(unit)]
		tooltip:AddLine(FORMAT_LEVEL_PLAYER:format(levelText, familyText))
		return true
	end
end)

-- replace money frame on tooltip with string alternative, which we can skin
TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.SellPrice, function(tooltip, lineData)
	tooltip:AddLine(SELL_PRICE .. ': ' .. GetMoneyString(lineData.price), WHITE_FONT_COLOR:GetRGB())
	return true
end)

-- skin tooltips and their health bars
do
	local function tooltipOnShow(self)
		if self.CompareHeader then
			-- slight tint so we can differentiate them easily
			self:SetBackgroundColor(0.1, 0.1, 0.1, 0.8)
			self:SetBorderColor(0.2, 0.2, 0.2)
		else
			self:SetBackgroundColor(0, 0, 0, 0.8)
			self:SetBorderColor(0, 0, 0, 1)
		end
	end

	local function tooltipHealthChanged(self)
		local tooltip = self:GetParent()
		self:SetStatusBarColor(tooltip.TextLeft1:GetTextColor())
	end

	function addon:SkinTooltip(tooltip)
		addon:Hide(tooltip, 'NineSlice')
		addon:AddBackdrop(tooltip)

		tooltip:HookScript('OnShow', tooltipOnShow)

		if tooltip.CompareHeader then
			-- hide "Equipped" header
			tooltip.CompareHeader:SetAlpha(0)
		end

		if tooltip.StatusBar then
			tooltip.StatusBar:ClearAllPoints()
			tooltip.StatusBar:SetPoint('BOTTOMLEFT')
			tooltip.StatusBar:SetPoint('BOTTOMRIGHT')
			tooltip.StatusBar:SetHeight(3)
			tooltip.StatusBar:SetStatusBarTexture(addon.TEXTURE)
			tooltip.StatusBar:HookScript('OnValueChanged', tooltipHealthChanged)
		end

		if tooltip.shoppingTooltips then
			for _, shoppingTooltip in next, tooltip.shoppingTooltips do
				addon:SkinTooltip(shoppingTooltip)
			end
		end
	end

	for _, tooltip in next, {
		'GameTooltip',
		-- 'AddonButtonTooltip', -- forbidden :(
	} do
		addon:SkinTooltip(_G[tooltip])
	end

	addon:SkinTooltip(addon:GetTooltip())
end

-- skin aura tooltip
AuraContainerInbound.SetTooltipBackdrop({
	-- we can't do pixel perfect borders, pretty much stuck with the old backdrop system
	backdropInfo = {
		bgFile = addon.TEXTURE,
		edgeFile = addon.TEXTURE,
		edgeSize = 1,
	},
	borderColor = CreateColor(0, 0, 0, 1),
	centerColor = CreateColor(0, 0, 0, 0.7),
})

-- set custom font
for _, tooltipFontString in next, {
	'GameTooltipHeaderText',
	'GameTooltipText',
	'GameTooltipTextSmall',
} do
	_G[tooltipFontString]:SetFont(addon.FONT, 12, 'SLUG,OUTLINE')
	_G[tooltipFontString]:SetShadowOffset(0, 0)
end
