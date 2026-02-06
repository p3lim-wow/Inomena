local _, addon = ...

-- disable addon minimap buttons
function addon:OnLogin()
	local LDBI = LibStub and LibStub('LibDBIcon-1.0', true)
	if LDBI then
		for _, buttonName in next, LDBI:GetButtonList() do
			addon:Hide('LibDBIcon10_' .. buttonName)
		end

		LDBI.RegisterCallback(self, 'LibDBIcon_IconCreated', function(_, _, buttonName)
			addon:Hide('LibDBIcon10_' .. buttonName)
		end)
	end
end

-- expose shape for other addons
function GetMinimapShape()
	return 'SQUARE'
end
