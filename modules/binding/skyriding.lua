local addonName, addon = ...

local ABILITIES = {
	{key = 'F', spellID = 372610}, -- Skyward Ascent
	{key = 'BUTTON4', spellID = 372608}, -- Surge Forward
	{key = 'BUTTON5', spellID = 361584}, -- Whirling Surge
	{key = 'E', spellID = 425782}, -- Second Wind
	{key = 'T', spellID = 403092}, -- Aerial Halt
}

-- create a state handler to set override bindings whenever the player is mounted
local overrideHandler = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate')
overrideHandler:SetAttribute('_onstate-skyriding', [[
	if newstate == 'mounted' then
		for index = 1, (self:GetAttribute('numButtons') or 0) do
			local ref = self:GetFrameRef('button' .. index)
			self:SetBindingClick(true, ref:GetAttribute('key'), ref)
		end
	elseif newstate == 'reset' then
		self:ClearBindings()
	end
]])

-- watch for spells
local numButtonsCreated = 0
local function updateSpells()
	if InCombatLockdown() then
		-- try again when combat ends
		if not addon:IsEventRegistered('PLAYER_REGEN_ENABLED', updateSpells) then
			addon:RegisterEvent('PLAYER_REGEN_ENABLED', updateSpells)
		end
		return
	end

	for _, ability in next, ABILITIES do
		if IsSpellKnown(ability.spellID) and not ability.button then
			-- create a button for each spell
			local button = addon:CreateButton('Button', addonName .. 'MountAbilityButton' .. ability.key, nil, 'SecureActionButtonTemplate')
			button:SetAttribute('type', 'spell')
			button:SetAttribute('spell', ability.spellID)
			button:SetAttribute('key', ability.key)
			ability.button = button

			-- update button count
			numButtonsCreated = numButtonsCreated + 1
			overrideHandler:SetAttribute('numButtons', numButtonsCreated)

			-- add a reference to it for the state handler
			overrideHandler:SetFrameRef('button' .. numButtonsCreated, button)
		end
	end

	if numButtonsCreated == #ABILITIES then
		RegisterStateDriver(overrideHandler, 'skyriding', '[bonusbar:5] mounted; reset')

		-- stop watching for changes
		if addon:IsEventRegistered('SPELLS_CHANGED', updateSpells) then
			addon:UnregisterEvent('SPELLS_CHANGED', updateSpells)
		end
	end

	if addon:IsEventRegistered('PLAYER_REGEN_ENABLED', updateSpells) then
		addon:UnregisterEvent('PLAYER_REGEN_ENABLED', updateSpells)
	end
end

addon:RegisterEvent('SPELLS_CHANGED', updateSpells)
