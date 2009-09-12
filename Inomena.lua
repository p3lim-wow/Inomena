local Inomena = CreateFrame('Frame', 'Inomena')

function Inomena:Register(event, method)
	self[event] = method
	self:RegisterEvent(event)
end

function Inomena:Print(...)
	print('|cffff8080Inomena:|r', ...)
end

Inomena:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)

-- Register my fonts with LSM
local SharedMedia = LibStub('LibSharedMedia-3.0')
SharedMedia:Register('font', 'Bitstream Vera Serif', [=[Interface\AddOns\Inomena\media\vera.ttf]=])
SharedMedia:Register('font', 'Marke Eigenbau', [=[Interface\AddOns\Inomena\media\marke.ttf]=])
