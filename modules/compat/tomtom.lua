local _, addon = ...

addon:RegisterSlash('/paste', function()
	-- cladhaire copied my paste implementation :)
	TomTomPaste:SetShown(not TomTomPaste:IsShown())
end)
