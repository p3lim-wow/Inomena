local addonName, addon = ...

local bindings = {}
function addon:BindButton(name, key, template)
	local button = self:CreateButton('Button', addonName .. 'Bind' .. name, nil, template)
	bindings[button:GetName()] = key
	return button
end

local bindParent = CreateFrame('Frame')
function addon:PLAYER_LOGIN()
	for button, key in next, bindings do
		SetOverrideBindingClick(bindParent, true, key, button)
	end
	return true
end
