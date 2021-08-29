local _, addon = ...

local CLASSIFICATION_TEXT = {
	worldboss = ' Boss|r',
	rareelite = '+|r Rare',
	rare = '|r Rare',
	elite = '+|r',
}

-- convencience table
local REACTION_COLORS = {}
for index, color in next, FACTION_BAR_COLORS do
	REACTION_COLORS[index] = CreateColor(color.r, color.g, color.b)
end

GameTooltip:HookScript('OnTooltipSetUnit', function(self)
	local _, unit = self:GetUnit()
	if not unit then
		return
	end

	-- start fresh
	GameTooltip:ClearLines()

	if UnitIsPlayer(unit) then
		self.color = RAID_CLASS_COLORS[UnitClassBase(unit)]
		GameTooltip:AddLine(self.color:WrapTextInColorCode(GetUnitName(unit, true)))

		local guildName = GetGuildInfo(unit)
		if guildName then
			if UnitIsInMyGuild(unit) then
				GameTooltip:AddLine('<' .. guildName .. '>', 0, 0.55, 1)
			else
				GameTooltip:AddLine('<' .. guildName .. '>', 0, 1, 0.1)
			end
		end

		local level = UnitLevel(unit)
		if UnitIsFriend(unit, 'player') then
			GameTooltip:AddLine(string.format('|cffffd000%s|r %s', level, UnitRace(unit)), 1, 1, 1)
		else
			local levelColor = GetDifficultyColor(C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit))
			local levelText = level > 0 and level or '??'
			GameTooltip:AddLine(string.format('%s |cffff3300%s|r', levelText, UnitRace(unit)), levelColor.r, levelColor.g, levelColor.b)
		end
	else
		self.color = REACTION_COLORS[UnitReaction(unit, 'player')]
		GameTooltip:AddLine(self.color:WrapTextInColorCode(UnitName(unit)))

		-- TODO: title (no API for this)

		if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
			GameTooltip:AddLine(string.format('|cffffff00%s|r %s', UnitBattlePetLevel(unit), _G['BATTLE_PET_NAME_' .. UnitBattlePetType(unit)]))
		else
			local level = UnitLevel(unit)
			local levelColor = GetDifficultyColor(C_PlayerInfo.GetContentDifficultyCreatureForPlayer(unit))

			local levelText = level > 0 and level or '??'
			local rarityText = CLASSIFICATION_TEXT[UnitClassification(unit)] or '|r'
			local creatureText = UnitCreatureFamily(unit) or UnitCreatureType(unit) or ''

			GameTooltip:AddLine(string.format('%s%s |cffffffff%s|r', levelText, rarityText, creatureText), levelColor.r, levelColor.g, levelColor.b)
		end

		-- TODO: faction (no API for this)
	end

	if not UnitIsDeadOrGhost(unit) then
		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint('BOTTOMLEFT', 2, 2)
		GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', -2, 2)
		GameTooltipStatusBar:SetStatusBarColor(self.color:GetRGB())
		GameTooltipStatusBar:Show()
	end

	self:Show()
end)

-- set a new backdrop
local function updateStyle(self)
	self:CreateBackdrop(0.7, 0)
end

Mixin(GameTooltip, addon.mixins.backdrop)
GameTooltip:HookScript('OnShow', updateStyle)
GameTooltip:HookScript('OnTooltipSetItem', updateStyle)

for _, shoppingTooltip in next, GameTooltip.shoppingTooltips do
	Mixin(shoppingTooltip, addon.mixins.backdrop)
	shoppingTooltip:HookScript('OnTooltipSetItem', updateStyle)
end

-- set a new font
for _, name in next, {
	'GameTooltipHeaderText',
	'GameTooltipText',
	'GameTooltipTextSmall', -- shoppingtooltips
} do
	local Text = _G[name]
	Text:SetFontObject(addon.FONT)
	Text:SetShadowOffset(0, 0)
end

-- set a new position
hooksecurefunc('GameTooltip_SetDefaultAnchor', function(self, parent)
	self:SetOwner(parent, 'ANCHOR_NONE')
	self:ClearAllPoints()
	self:SetPoint('BOTTOMRIGHT', -50, 50)
end)

-- style the health bar
GameTooltipStatusBar:SetHeight(3)
GameTooltipStatusBar:SetStatusBarTexture(addon.TEXTURE)

local background = GameTooltipStatusBar:CreateTexture('$parentBackground', 'BACKGROUND')
background:SetAllPoints()
background:SetColorTexture(1/4, 1/4, 1/4)

-- make sure the status bar isn't shown for non-units
GameTooltip:HookScript('OnSizeChanged', function(self)
	if not UnitExists('mouseover') then
		GameTooltipStatusBar:Hide()
	end
end)
