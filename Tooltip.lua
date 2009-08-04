local classification = {
	worldboss = ' Boss|r',
	rareelite = '+|r Rare',
	rare = '|r Rare',
	elite = '+|r',
}

local function hex(r, g, b)
	if type(r) == "table" then
		if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

local function smartScript(self, script, handler)
	if(self:GetScript(script)) then
		self:HookScript(script, handler)
	else
		self:SetScript(script, handler)
	end
end

smartScript(GameTooltip, 'OnUpdate', function(self)
	if(self.class and UnitIsPlayer('mouseover')) then
		local x = RAID_CLASS_COLORS[self.class]
		GameTooltipStatusBar:SetStatusBarColor(x.r, x.g, x.b)
	end

	if(UnitExists('mouseover') and self.height and self.height ~= self:GetHeight()) then
		self:SetHeight(self.height)
	end
end)

smartScript(GameTooltip, 'OnShow', function(self)
	for index = 2, self:NumLines() do
		if(_G['GameTooltipTextLeft'..index]:GetText() == PVP_ENABLED) then
			_G['GameTooltipTextLeft'..index]:SetText()
			break
		end
	end

	if(GameTooltipStatusBar:IsShown() and UnitExists('mouseover')) then
		if(UnitIsPVP('mouseover')) then
			self:SetHeight(self:GetHeight() - 3)
		else
			self:SetHeight(self:GetHeight() + 11)
		end

		self.height = self:GetHeight()
	end
end)

smartScript(GameTooltip, 'OnTooltipSetUnit', function(self)
	local _, unit = self:GetUnit()
	if(not unit or not UnitExists(unit)) then return end

	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint('BOTTOMLEFT', 8, 9)
	GameTooltipStatusBar:SetPoint('BOTTOMRIGHT', -8, 9)
	GameTooltipStatusBar:SetStatusBarTexture([=[Interface\AddOns\Inomena\media\minimalist]=])
	GameTooltipStatusBar:SetHeight(7)

	if(not GameTooltipStatusBar.bg) then
		GameTooltipStatusBar.bg = GameTooltipStatusBar:CreateTexture(nil, 'BACKGROUND')
		GameTooltipStatusBar.bg:SetAllPoints(GameTooltipStatusBar)
		GameTooltipStatusBar.bg:SetTexture(0.4, 0.4, 0.4)
	end

	local level = UnitLevel(unit)
	local guild = GetGuildInfo(unit)
	local name, realm = UnitName(unit)
	local localized, class = UnitClass(unit)
	local index = GetRaidTargetIndex(unit)
	local GameTooltipTextLeftX

	for index = 2, self:NumLines() do
		local line = _G['GameTooltipTextLeft'..index]
		local levelLine = line:GetText():find('^'..TOOLTIP_UNIT_LEVEL:gsub('%%s', '.+'))

		if(levelLine) then
			GameTooltipTextLeftX = line
		end
	end

	if(UnitIsPlayer(unit)) then
		GameTooltipTextLeft1:SetFormattedText('%s%s%s|r%s', index and format('%s22|t', ICON_LIST[index]) or '', hex(RAID_CLASS_COLORS[class]), name, realm and realm ~= '' and ' (*)' or '')
		GameTooltipTextLeftX:SetFormattedText('%s%s|r %s %s', hex(GetDifficultyColor(level > 0 and level or 99)), level > 0 and level or '??', UnitRace(unit), UnitIsAFK(unit)and CHAT_FLAG_AFK or UnitIsDND(unit) and CHAT_FLAG_DND or not UnitIsConnected(unit) and '<DC>' or '')

		if(guild) then -- better checks
			GameTooltipTextLeft2:SetFormattedText('|cff%s<%s>|r', IsInGuild() and GetGuildInfo('player') == guild and '0090ff' or '00ff10', guild)
		end

		self.class = class
	else
		GameTooltipTextLeft1:SetFormattedText('%s%s', index and format('%s22|t', ICON_LIST[index]) or '', name) -- add reaction color
		GameTooltipTextLeftX:SetFormattedText('%s%s%s|r %s',  hex(GetDifficultyColor(level > 0 and level or 99)), level > 0 and level or '??', classification[UnitClassification(unit)] or '', UnitCreatureFamily(unit) or UnitCreatureType(unit))
		-- do something to minion stuff (like guild)
	end
end)

for k, v in next, {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3} do
	v:SetBackdrop({bgFile = [=[Interface\Tooltips\UI-Tooltip-Background]=]})
	v:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
end
