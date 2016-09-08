local E, F = unpack(select(2, ...))

local tabs = {}
local function OnTabClick()
	for index, Tab in next, tabs do
		local current = IsCurrentSpell(Tab.name)
		Tab:SetChecked(current)
		Tab:SetButtonState(current and 'DISABLED' or 'NORMAL')
	end
end

local VellumButton
local function OnRecipesRefresh(self)
	if(InCombatLockdown()) then
		VellumButton:SetAlpha(0)
		return
	else
		VellumButton:SetAlpha(1)
	end

	if(self.createVerbOverride and self.createVerbOverride == 'Enchant') then
		VellumButton:Show()

		local numVellums = GetItemCount(38682)
		if(numVellums == 0 or not self.craftable) then
			VellumButton:Disable()
		elseif(self.craftable) then
			VellumButton:Enable()
		end

		VellumButton:SetFormattedText('%s (%d)', VellumButton.name, numVellums)
	else
		VellumButton:Hide()
	end
end

local function CombatDisabled()
	if(TradeSkillFrame.DetailsFrame:IsVisible()) then
		OnRecipesRefresh(TradeSkillFrame.DetailsFrame)
	end
end

local function CreateVellumButton()
	VellumButton = CreateFrame('Button', 'VellumButton', TradeSkillFrame.DetailsFrame, 'SecureActionButtonTemplate, MagicButtonTemplate')
	VellumButton:SetPoint('TOPRIGHT', TradeSkillFrame.DetailsFrame.CreateButton, 'TOPLEFT')
	VellumButton:SetSize(88, 22)
	VellumButton.name = GetSpellInfo(162250)
	VellumButton:SetAttribute('type', 'macro')
	VellumButton:SetAttribute('macrotext', '/run TradeSkillFrame.DetailsFrame:Create()\n/use item:38682')
	VellumButton:Hide()

	hooksecurefunc(TradeSkillFrame.DetailsFrame, 'RefreshDisplay', OnRecipesRefresh)

	if(TradeSkillFrame.DetailsFrame:IsVisible()) then
		OnRecipesRefresh(TradeSkillFrame.DetailsFrame)
	end

	E:RegisterEvent('PLAYER_REGEN_ENABLED', CombatDisabled)

	return true
end

function E:ADDON_LOADED(addonName)
	if(addonName ~= 'Blizzard_TradeSkillUI') then
		return
	end

	-- profession tabs
	for index, id in next, {GetProfessions()} do
		if(id and index ~= 4 and index ~= 3) then -- ignore fishing and archaeology
			local name, texture, rank, maxRank = GetProfessionInfo(id)
			local Tab = CreateFrame('CheckButton', nil, TradeSkillFrame, 'SpellBookSkillLineTabTemplate, SecureActionButtonTemplate')
			Tab:SetAttribute('type', 'spell')
			Tab:SetAttribute('spell', name)
			Tab:SetNormalTexture(texture)
			Tab:SetID(index)
			Tab:SetMotionScriptsWhileDisabled(true)
			Tab:HookScript('OnClick', OnTabClick)
			Tab.name = name
			Tab.tooltip = string.format(ITEM_SET_NAME, name, rank, maxRank)

			if(#tabs == 0) then
				Tab:SetPoint('TOPLEFT', TradeSkillFrame, 'TOPRIGHT', 0, -36)
			else
				Tab:SetPoint('TOPLEFT', tabs[#tabs], 'BOTTOMLEFT', 0, -17)
			end
			Tab:Show()

			tabs[#tabs + 1] = Tab
		end
	end

	E:RegisterEvent('TRADE_SKILL_SHOW', OnTabClick)
	OnTabClick()

	-- vellum button
	if(IsSpellKnown(13262)) then -- Enchanting
		if(InCombatLockdown()) then
			E:RegisterEvent('PLAYER_REGEN_ENABLED', CreateVellumButton)
		else
			CreateVellumButton()
		end
	end

	return true
end
