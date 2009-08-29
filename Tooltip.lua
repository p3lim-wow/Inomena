local _G = getfenv(0)
local find, gsub, format = string.find, string.gsub, string.format

local classification = {
	worldboss = ' Boss|r',
	rareelite = '+|r Rare',
	rare = '|r Rare',
	elite = '+|r',
}

local function hex(c)
	return format('|cff%02x%02x%02x', c.r * 255, c.g * 255, c.b * 255)
end

GameTooltip:HookScript('OnUpdate', function(self)
	if(self.class and UnitIsPlayer('mouseover')) then
		local c = RAID_CLASS_COLORS[self.class]
		GameTooltipStatusBar:SetStatusBarColor(c.r, c.g, c.b)
	end

	for index = 2, self:NumLines() do
		if(_G['GameTooltipTextLeft'..index]:GetText() == PVP_ENABLED) then
			_G['GameTooltipTextLeft'..index]:SetText()
			break
		end
	end

	self:Show()
end)

GameTooltip:HookScript('OnShow', function(self)
	if(GameTooltipStatusBar:IsShown()) then
		self:AddLine(' ') -- find a better way to handle this, but it works for now
	end
end)

GameTooltip:HookScript('OnTooltipSetUnit', function(self)
	local _, unit = self:GetUnit()
	if(not unit or not UnitExists(unit)) then return end

	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint('BOTTOMLEFT', 8, 9)
	GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', -8, 9)


	local level = UnitLevel(unit)
	local guild = GetGuildInfo(unit)
	local name, realm = UnitName(unit)
	local localized, class = UnitClass(unit)
	local index = GetRaidTargetIndex(unit)
	local nameLine, titleLine, infoLine = GameTooltipTextLeft1

	for index = 2, self:NumLines() do
		local line = _G['GameTooltipTextLeft'..index]
		local levelLine = line:GetText():find('^'..TOOLTIP_UNIT_LEVEL:gsub('%%s', '.+'))

		if(levelLine) then
			infoLine = line
		elseif(index == 2 and not levelLine) then
			titleLine = line
		end
	end

	if(UnitIsPlayer(unit)) then
		nameLine:SetFormattedText('%s%s%s|r%s', index and format('%s22|t', ICON_LIST[index]) or '', hex(RAID_CLASS_COLORS[class]), name, realm and realm ~= '' and ' (*)' or '')
		infoLine:SetFormattedText('%s%s|r %s %s', hex(GetQuestDifficultyColor(UnitIsFriend(unit, 'player') and UnitLevel('player') or level > 0 and level or 99)), level > 0 and level or '??', UnitRace(unit), UnitIsAFK(unit)and CHAT_FLAG_AFK or UnitIsDND(unit) and CHAT_FLAG_DND or not UnitIsConnected(unit) and '<DC>' or '')

		if(guild and titleLine) then
			titleLine:SetFormattedText('|cff%s<%s>|r', IsInGuild() and GetGuildInfo('player') == guild and '0090ff' or '00ff10', guild)
		end

		self.class = class
	else
		nameLine:SetFormattedText('%s%s', index and format('%s22|t', ICON_LIST[index]) or '', name) -- add reaction color
		infoLine:SetFormattedText('%s%s%s|r %s', hex(GetQuestDifficultyColor(UnitIsFriend(unit, 'player') and UnitLevel('player') or level > 0 and level or 99)), level > 0 and level or '??', classification[UnitClassification(unit)] or '', UnitCreatureFamily(unit) or UnitCreatureType(unit) or '')

		if(titleLine) then
			titleLine:SetFormattedText('<%s>', titleLine:GetText())
		end
	end
end)

GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil, 'BACKGROUND')
GameTooltipStatusBar.bg:SetAllPoints(GameTooltipStatusBar)
GameTooltipStatusBar.bg:SetTexture(0.4, 0.4, 0.4)

GameTooltipStatusBar:SetHeight(7)
GameTooltipStatusBar:SetStatusBarTexture([=[Interface\AddOns\Inomena\media\minimalist]=])

for k, v in next, {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3} do
	v:SetBackdrop({bgFile = [=[Interface\Tooltips\UI-Tooltip-Background]=]})
end
