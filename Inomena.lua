local _, ns = ...

local addon = CreateFrame('Frame')
addon:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)

ns.Register = function(event, method)
	addon[event] = method
	addon:RegisterEvent(event)
end
