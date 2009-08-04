local classification = {
	worldboss = ' Boss|r',
	rareelite = '+|r Rare',
	rare = '|r Rare',
	elite = '+|r',
}

local reactionColor = {} -- todo

local function smartScript(self, script, handler)
	if(self:GetScript(script)) then
		self:HookScript(script, handler)
	else
		self:SetScript(script, handler)
	end
end

smartScript(GameTooltip, 'OnUpdate', function(self)
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

	local index = GetRaidTargetIndex(unit)
	local name, realm = UnitName(unit)

	if(UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		local color = RAID_CLASS_COLORS[class]
		if(index) then
			GameTooltipTextLeft1:SetFormattedText('%s22|t |cff%02x%02x%02x%s|r %s', ICON_LIST[index], color.r * 255, color.g * 255, color.b * 255, name, realm and realm ~= '' and realm ~= GetRealmName() and '(*)' or '')
		else
			GameTooltipTextLeft1:SetFormattedText('|cff%02x%02x%02x%s|r %s', color.r * 255, color.g * 255, color.b * 255, name, realm and realm ~= '' and realm ~= GetRealmName() and '(*)' or '')
		end
	
		local guild = GetGuildInfo(unit)
		if(guild) then
			if(IsInGuild() and GetGuildInfo('player') == guild) then
				GameTooltipTextLeft2:SetFormattedText('|cff0090ff<%s>|r', guild)
			else
				GameTooltipTextLeft2:SetFormattedText('|cff00ff10<%s>|r', guild)
			end
		end
	else
		local color = reactionColor[UnitReaction(unit, 'player')] or {r = 1, g = 1, b = 1}
		if(index) then
			GameTooltipTextLeft1:SetFormattedText('%s22|t |cff%02x%02x%02x%s|r', ICON_LIST[index], color.r * 255, color.g * 255, color.b * 255, name)
		else
			GameTooltipTextLeft1:SetFormattedText('|cff%02x%02x%02x%s|r', color.r * 255, color.g * 255, color.b * 255, name)
		end

--		GameTooltipTextLeft2:SetFormattedText('<%s>', GameTooltipTextLeft2:GetText()) -- npc title
	end

	local level = UnitLevel(unit)
	local color = GetDifficultyColor(level > 0 and level or 99)

	for index = 2, self:NumLines() do
		local line = _G['GameTooltipTextLeft'..index]
		if(line:GetText():find('^'..LEVEL)) then
			if(UnitIsPlayer(unit)) then
				line:SetFormattedText('|cff%02x%02x%02x%s|r %s %s', color.r * 255, color.g * 255, color.b * 255, level > 0 and level or '??', UnitRace(unit), UnitIsAFK(unit)and CHAT_FLAG_AFK or UnitIsDND(unit) and CHAT_FLAG_DND or not UnitIsConnected(unit) and '<DC>' or '')
			else
				line:SetFormattedText('|cff%02x%02x%02x%s%s|r %s', color.r * 255, color.g * 255, color.b * 255, level > 0 and level or '??', classification[UnitClassification(unit)] or '', UnitCreatureFamily(unit) or UnitCreatureType(unit))
			end
			break
		end
	end
end)

for k, v in next, {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3} do
	v:SetBackdrop({bgFile = [=[Interface\Tooltips\UI-Tooltip-Background]=]})
	v:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
end
