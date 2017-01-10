local E, F, C = unpack(select(2, ...))

local TOOLTIP_LEVEL = string.gsub(TOOLTIP_UNIT_LEVEL, '%%s', '.+')

local classifications = {
	worldboss = ' Boss|r',
	rareelite = '+|r Rare',
	rare = '|r Rare',
	elite = '+|r',
}

local function GetColor(unit)
	if(UnitIsPlayer(unit) and not UnitHasVehicleUI(unit)) then
		local _, classToken = UnitClass(unit)
		return (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[classToken]
	else
		return FACTION_BAR_COLORS[UnitReaction(unit, 'player')]
	end
end

local WHITE = {r = 1, g = 1, b = 1}
GameTooltip:HookScript('OnTooltipSetUnit', function(self)
	local _, unit = self:GetUnit()
	if(not unit) then
		return
	end

	local color = GetColor(unit) or WHITE
	GameTooltipTextLeft1:SetFormattedText('%s%s', ConvertRGBtoColorString(color), GetUnitName(unit, true))

	local guildName = GetGuildInfo(unit)

	for index = 2, self:NumLines() do
		local line = _G['GameTooltipTextLeft' .. index]
		local lineText = line:GetText()

		if(guildName and string.find(lineText, guildName)) then
			if(UnitIsInMyGuild(unit)) then
				line:SetFormattedText('|cff0090ff<%s>|r', guildName)
			else
				line:SetFormattedText('|cff00ff10<%s>|r', guildName)
			end
		end

		if(string.find(lineText, TOOLTIP_LEVEL)) then
			local level = UnitLevel(unit)
			local levelText = level > 0 and level or '??'
			local levelDifficulty = UnitIsFriend(unit, 'player') and UnitLevel('player') or level > 0 and level or 999
			local levelColor = ConvertRGBtoColorString(GetQuestDifficultyColor(levelDifficulty))

			if(UnitIsPlayer(unit)) then
				local flags = UnitIsAFK(unit) and CHAT_FLAG_AFK or UnitIsDND(unit) and CHAT_FLAG_DND or ''

				if(UnitFactionGroup(unit) ~= UnitFactionGroup('player')) then
					line:SetFormattedText('%s%s|r |cffff3300%s|r %s', levelColor, levelText, UnitRace(unit), flags)
				else
					line:SetFormattedText('%s%s|r |cffffffff%s|r %s', levelColor, levelText, UnitRace(unit), flags)
				end
			else
				local creatureText
				if(UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
					level = UnitBattlePetLevel(unit)
					levelColor = '|cffffff00'

					creatureText = _G['BATTLE_PET_NAME_' .. UnitBattlePetType(unit)]
				else
					creatureText = UnitCreatureFamily(unit) or UnitCreatureType(unit) or ''
				end

				local classification = classifications[UnitClassification(unit)] or '|r'
				line:SetFormattedText('%s%s%s %s', levelColor, levelText, classification, creatureText)
			end
		end

		if
			string.find(lineText, PVP) or
			string.find(lineText, FACTION_ALLIANCE) or
			string.find(lineText, FACTION_HORDE)
		then
			line:Hide()
		end
	end

	if(not UnitIsDeadOrGhost(unit)) then
		GameTooltipStatusBar:ClearAllPoints()
		GameTooltipStatusBar:SetPoint('BOTTOMLEFT', 2, 2)
		GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', -2, 2)
		GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
		GameTooltipStatusBar.color = color
	else
		GameTooltipStatusBar:Hide()
	end

	self:Show()
end)

hooksecurefunc('GameTooltip_SetDefaultAnchor', function(self, parent)
	self:SetOwner(parent, 'ANCHOR_NONE')
	self:ClearAllPoints()
	self:SetPoint('BOTTOMRIGHT', -50, 50)
end)

local function SetPosition(self)
	self:ClearAllPoints()
	self:SetPoint('BOTTOMRIGHT', -50, 50)
end

GameTooltipStatusBar:SetHeight(3)
GameTooltipStatusBar:SetStatusBarTexture(C.PlainTexture)
GameTooltipStatusBar:HookScript('OnValueChanged', function(self)
	local color = self.color
	if(color) then
		self:SetStatusBarColor(color.r, color.g, color.b)
	end
end)

local HealthBackground = GameTooltipStatusBar:CreateTexture('$parentBackground', 'BACKGROUND')
HealthBackground:SetAllPoints()
HealthBackground:SetColorTexture(1/4, 1/4, 1/4)

local function SetBackdropColor(self)
	self:SetBackdropColor(0, 0, 0, 0.6)
end

for _, name in next, {
	'GameTooltip',
	'ShoppingTooltip1',
	'ShoppingTooltip2',
	'ItemRefTooltip',
	'ItemRefShoppingTooltip1',
	'ItemRefShoppingTooltip2',
	'WorldMapTooltip',
} do
	local Tooltip = _G[name]
	Tooltip:SetBackdrop(C.InsetBackdrop)
	Tooltip:HookScript('OnShow', SetBackdropColor)
	Tooltip:HookScript('OnHide', SetBackdropColor)
	Tooltip:HookScript('OnTooltipCleared', SetBackdropColor)
end

for _, name in next, {
	'GameTooltipHeaderText',
	'GameTooltipText',
	'GameTooltipTextSmall', -- shoppingtooltip
} do
	local Text = _G[name]
	Text:SetFont(C.Font, C.FontSize, C.FontFlags)
	Text:SetShadowOffset(0, 0)
end
