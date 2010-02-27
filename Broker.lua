local LDB = LibStub('LibDataBroker-1.1')

local data = LDB:GetDataObjectByName('Broker_Equipment')
if(data) then
	local object = CreateFrame('Button', nil, UIParent)
	object:SetPoint('BOTTOMRIGHT', Minimap, -1, 1)
	object:RegisterForClicks('AnyUp')
	object:SetHeight(12)
	object:SetWidth(12)
	object:SetAlpha(0)
	object:SetScript('OnLeave', function(self) self:SetAlpha(0) end)
	object:SetScript('OnEnter', function(self) self:SetAlpha(1) end)
	object:SetScript('OnClick', data.OnClick)

	local icon = object:CreateTexture(nil, 'OVERLAY')
	icon:SetAllPoints(object)
	icon:SetTexture(data.icon)

	LDB.RegisterCallback(object, 'LibDataBroker_AttributeChanged_Broker_Equipment', function()
		icon:SetTexture(data.icon)
	end)
end
