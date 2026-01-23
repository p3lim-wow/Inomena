local _, addon = ...

-- no idea why plusmouse doesn't use this way easier to remember command that is not reserved

addon:HookAddOn('Syndicator', function()
	addon:RegisterSlash('/find', Syndicator.Search.RunMegaSearchAndPrintResults)
end)
