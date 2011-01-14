local _, Inomena = ...

Inomena.Register('ADDON_LOADED', function(name)
	if(name ~= 'Blizzard_GuildUI') then return end

	GuildFrame:HookScript('OnShow', function()
		GuildFrameTab2:Click()
	end)
end)

