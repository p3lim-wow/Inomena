local addonName, addon = ...

local button = addon:CreateButton('Button', addonName .. 'Repair', Minimap, 'SecureActionButtonTemplate')
button:SetPoint('BOTTOMRIGHT', -7, 7)
button:SetSize(30, 30)

local icon = button:CreateTexture(nil, 'OVERLAY')
icon:SetPoint('CENTER')
icon:SetAtlas('repair', true)
icon:SetScale(0.8)

function addon:UPDATE_INVENTORY_DURABILITY()
	local _, lowest = addon:GetDurability()
	icon:SetAlpha(lowest < 0.2 and 1 or 0)
end
