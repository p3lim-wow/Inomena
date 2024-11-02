local _, addon = ...

addon:HookAddOn('TomTom', function()
	addon:RegisterSlash('/paste', function()
		-- cladhaire copied my old paste implementation, but the command is not memorable enough
		TomTomPaste:SetShown(not TomTomPaste:IsShown())
	end)
end)
