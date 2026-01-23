local addonName, addon = ...

local bindMixin = {}
function bindMixin:Bind(key)
	addon:Defer('SetOverrideBindingClick', self, true, key, self:GetName())
end

function bindMixin:Unbind()
	addon:Defer('ClearOverrideBindings', self)
end

function addon:CreateBindButton(name, template)
	local buttonName = addonName .. 'Bind' .. name
	return Mixin(self:CreateButton('Button', buttonName, nil, template), bindMixin) -- from Dashi
end
