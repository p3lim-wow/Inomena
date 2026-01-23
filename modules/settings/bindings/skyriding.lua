local addonName, addon = ...

-- bind skyriding abilities to specific keys
-- this removes the need to micro-manage these abilities on every character

local TEMPLATES = 'SecureActionButtonTemplate, SecureHandlerStateTemplate'
local STATE_HANDLER = [[
	if newstate == 'mounted' then
		self:SetBindingClick(true, self:GetAttribute('key'), self)
	elseif newstate == 'reset' then
		self:ClearBindings()
	end
]]

for _, bindAbilityMap in next, {
	{key = 'BUTTON4', spellID = 372608, condition = '[bonusbar:5]'}, -- Surge Forward / Lightning Rush
	{key = 'BUTTON5', spellID = 361584, condition = '[bonusbar:5]'}, -- Whirling Surge
	{key = 'E',       spellID = 425782, condition = '[bonusbar:5]'}, -- Second Wind
	{key = 'T',       spellID = 403092, condition = '[bonusbar:5]'}, -- Aerial Halt
	{key = 'F',       spellID = 372610, condition = '[bonusbar:5]'}, -- Skyward Ascent
	{key = 'SPACE',   spellID = 372610, condition = '[bonusbar:5,flying]'}, -- Skyward Ascent
} do
	local buttonName = addonName .. 'Bind' .. bindAbilityMap.key -- required for SetBindingClick
	local button = addon:CreateButton('Button', buttonName, nil, TEMPLATES)
	button:SetAttribute('type', 'spell')
	button:SetAttribute('spell', bindAbilityMap.spellID)
	button:SetAttribute('key', bindAbilityMap.key)
	button:SetAttribute('_onstate-skyriding', STATE_HANDLER)

	RegisterStateDriver(button, 'skyriding', bindAbilityMap.condition .. 'mounted; reset')
end
