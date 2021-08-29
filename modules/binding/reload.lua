local _, addon = ...

local reload = addon:CreateButton('BindReload')
reload:SetScript('OnClick', ReloadUI)
reload:RegisterEvent('PLAYER_LOGIN', function(self)
	SetBindingClick('F12', self:GetName())

	return true
end)
