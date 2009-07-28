local Inomena = CreateFrame('Frame', 'Inomena')

function Inomena:Register(event, method)
	self[event] = method
	self:RegisterEvent(event)
end

Inomena:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
