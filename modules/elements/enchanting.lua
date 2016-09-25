local E, F, C = unpack(select(2, ...))

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

local function OnCombatEnded()
	if(TradeSkillFrame.DetailsFrame:IsVisible()) then
		OnRecipesRefresh(TradeSkillFrame.DetailsFrame)
	end
end

local function CreateVellumButton()
	VellumButton = CreateFrame('Button', C.Name .. 'VellumButton', TradeSkillFrame.DetailsFrame, 'SecureActionButtonTemplate, MagicButtonTemplate')
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

	E:RegisterEvent('PLAYER_REGEN_ENABLED', OnCombatEnded)

	return true
end

function E:ADDON_LOADED(addonName)
	if(addonName == 'Blizzard_TradeSkillUI') then
		if(IsSpellKnown(13262)) then -- Enchanting
			if(InCombatLockdown()) then
				E:RegisterEvent('PLAYER_REGEN_ENABLED', CreateVellumButton)
			else
				CreateVellumButton()
			end
		end

		return true
	end
end
