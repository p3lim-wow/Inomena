local E, F, C = unpack(select(2, ...))

local TOOLTIP_LEVEL = TOOLTIP_UNIT_LEVEL:gsub('%%s', '.+')
local CLASSIFICATION_TEXT = {
	worldboss = ' Boss|r',
	rareelite = '+|r Rare',
	rare = '|r Rare',
	elite = '+|r',
}

local BACKDROP = CopyTable(C.InsetBackdrop)
BACKDROP.backdropColor = CreateColor(0, 0, 0, 0.6)
BACKDROP.backdropColor.GetRGB = ColorMixin.GetRGBA
GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT = BACKDROP

local REACTION_COLORS = {}
for index, color in next, FACTION_BAR_COLORS do
	REACTION_COLORS[index] = CreateColor(color.r, color.g, color.b)
end

local function GetUnitColor(unit)
	local color
	if(UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local _, classToken = UnitClass(unit)
		color = RAID_CLASS_COLORS[classToken]
	else
		color = REACTION_COLORS[UnitReaction(unit, 'player')]
	end

	return color or HIGHLIGHT_FONT_COLOR
end

local function UpdateStyle(self)
	self:SetBackdrop(BACKDROP)
	self:SetBackdropColor(BACKDROP.backdropColor:GetRGBA())
end

local function UpdateUnit(self)
	local _, unit = self:GetUnit()
	if(not unit) then
		return
	end

	local tooltipName = self:GetName()
	local guildName = GetGuildInfo(unit)

	local color = GetUnitColor(unit)
	_G[tooltipName .. 'TextLeft1']:SetFormattedText('|c%s%s|r', color:GenerateHexColor(), GetUnitName(unit, true) or '')

	for index = 2, self:NumLines() do
		local line = _G[tooltipName .. 'TextLeft' .. index]
		local lineText = line:GetText()

		if(guildName and lineText:find(guildName)) then
			if(UnitIsInMyGuild(unit)) then
				line:SetFormattedText('|cff0090ff<%s>|r', guildName)
			else
				line:SetFormattedText('|cff00ff10<%s>|r', guildName)
			end
		end

		if(lineText:find(TOOLTIP_LEVEL)) then
			local level = UnitLevel(unit)
			local levelText = level > 0 and level or '??'
			local levelDifficulty = UnitIsFriend(unit, 'player') and UnitLevel('player') or level > 0 and level or 9999
			local levelColor = ConvertRGBtoColorString((GetCreatureDifficultyColor(levelDifficulty)))

			if(UnitIsPlayer(unit)) then
				local flags = UnitIsAFK(unit) and CHAT_FLAG_AFK or
							  UnitIsDND(unit) and CHAT_FLAG_DND

				local factionColor
				if(UnitFactionGroup(unit) ~= UnitFactionGroup('player')) then
					factionColor = 'ffff3300'
				else
					factionColor = 'ffffffff'
				end

				line:SetFormattedText('%s%s|r |c%s%s|r %s', levelColor, levelText, factionColor, UnitRace(unit), flags or '')
			else
				local creatureText
				if(UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
					levelText = UnitBattlePetLevel(unit)
					levelColor = '|cffffff00'

					creatureText = _G['BATTLE_PET_NAME_' .. UnitBattlePetType(unit)]
				else
					creatureText = UnitCreatureFamily(unit) or UnitCreatureType(unit) or ''
				end

				local classification = CLASSIFICATION_TEXT[UnitClassification(unit)] or '|r'
				line:SetFormattedText('%s%s%s %s', levelColor, levelText, classification, creatureText)
			end
		end

		if(lineText:find(PVP) or lineText:find(FACTION_ALLIANCE) or lineText:find(FACTION_HORDE)) then
			line:Hide()
		end
	end

	if(not UnitIsDeadOrGhost(unit)) then
		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint('BOTTOMLEFT', 2, 2)
		GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', -2, 2)
		GameTooltipStatusBar:SetStatusBarColor(color:GetRGB())
		GameTooltipStatusBar.color = color
	else
		GameTooltipStatusBar:Hide()
	end

	self:Show()
end

for _, tooltip in next, {
	GameTooltip,
	WorldMapTooltip,
} do
	tooltip:HookScript('OnShow', UpdateStyle)
	tooltip:HookScript('OnUpdate', UpdateStyle) -- because of the damn object tooltips blue color
	tooltip:HookScript('OnTooltipSetUnit', UpdateUnit)

	for _, shoppingTooltip in next, tooltip.shoppingTooltips do
		shoppingTooltip:HookScript('OnTooltipSetItem', UpdateStyle)
	end
end

for _, name in next, {
	'GameTooltipHeaderText',
	'GameTooltipText',
	'GameTooltipTextSmall', -- shoppingtooltips
} do
	local Text = _G[name]
	Text:SetFontObject('PixelFontNormal')
	Text:SetShadowOffset(0, 0)
end

hooksecurefunc('GameTooltip_SetDefaultAnchor', function(self, parent)
	self:SetOwner(parent, 'ANCHOR_NONE')
	self:ClearAllPoints()
	self:SetPoint('BOTTOMRIGHT', -50, 50)
end)

GameTooltipStatusBar:SetHeight(3)
GameTooltipStatusBar:SetStatusBarTexture(C.PlainTexture)
GameTooltipStatusBar:HookScript('OnValueChanged', function(self)
	if(self.color) then
		self:SetStatusBarColor(self.color:GetRGB())
	end
end)

local Background = GameTooltipStatusBar:CreateTexture('$parentBackground', 'BACKGROUND')
Background:SetAllPoints()
Background:SetColorTexture(1/4, 1/4, 1/4)
