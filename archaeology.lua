local _, Inomena = ...

StaticPopupDialogs.ARCHAEOLOGY_SOLVE = {
	text = '%s',
	button1 = SOLVE,
	button2 = IGNORE,
	OnAccept = SolveArtifact,
	timeout = 0,
}

local fragment = {
	['384'] = 1, -- Dwarf
	['385'] = 8, -- Troll
	['393'] = 3, -- Fossil
	['394'] = 4, -- Night Elf
	['397'] = 6, -- Orc
	['398'] = 2, -- Draenei
	['399'] = 9, -- Vrykul
	['400'] = 5, -- Nerubian
	['401'] = 7, -- Tol'vir
}

local _CURRENCY = string.gsub(string.gsub(CURRENCY_GAINED_MULTIPLE, '%%s', '(.+)'), '%%d', '(.+)')

Inomena.RegisterEvent('CHAT_MSG_CURRENCY', function(message)
	local link = string.match(message, _CURRENCY)
	local id = string.match(link, ':(%d+)|h')

	local race = fragment[id]
	if(race) then
		SetSelectedArtifact(race)

		local race, _, stone = GetArchaeologyRaceInfo(race)
		local artifact, _, rare, _, _, stones = GetSelectedArtifactInfo()

		for index = 1, math.min(stones, GetItemCount(stone)) do
			if(not ItemAddedToArtifact(index)) then
				SocketItemToArtifact()
			end
		end

		local fragments, stones, total = GetArtifactProgress()
		if(fragments + stones >= total) then
			local color
			if(rare and rare > 0) then
				color = '|cff0070dd'
			else
				color = '|cff9d9d9d'
			end

			StaticPopup_Show('ARCHAEOLOGY_SOLVE', string.format('%s %s: %s[%s]|r?', SOLVE, race, color, artifact))
		end
	end
end)
