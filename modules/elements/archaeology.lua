local E = unpack(select(2, ...))

StaticPopupDialogs.ARCHAEOLOGY_SOLVE = {
	text = '%s',
	button1 = SOLVE,
	button2 = IGNORE,
	OnAccept = SolveArtifact,
	timeout = 0
}

-- http://www.wowhead.com/currencies/archaeology
-- /run for i=1, GetNumArchaeologyRaces() do print(i, (GetArchaeologyRaceInfo(i))) end
local fragmentRaceIndices = {
	[384] = 18, -- Dwarf
	[385] = 11, -- Troll
	[393] = 16, -- Fossil
	[394] = 15, -- Night Elf
	[397] = 13, -- Orc
	[398] = 17, -- Draenei
	[399] = 10, -- Vrykul
	[400] = 14, -- Nerubian
	[401] = 12, -- Tol'vir
	[676] = 8, -- Pandaren
	[677] = 7, -- Mogu
	[754] = 9, -- Mantid
	[821] = 5, -- Draenor Clans
	[828] = 4, -- Ogre
	[829] = 6, -- Arakkoa
	[1172] = 3, -- Highborne
	[1173] = 2, -- Highmountain Tauren
	[1174] = 1, -- Demonic
}

local CURRENCY_MESSAGE = string.gsub(string.gsub(CURRENCY_GAINED_MULTIPLE, '%%s', '(.+)'), '%%d', '(.+)')

function E:CHAT_MSG_CURRENCY(message)
	local link = string.match(message, CURRENCY_MESSAGE)
	if(not link) then
		return
	end

	local fragmentID = string.match(link, ':(%d+)|h')
	local raceIndex = fragmentRaceIndices[tonumber(fragmentID)]
	if(not raceIndex) then
		return
	end

	SetSelectedArtifact(raceIndex)

	local raceName, _, keystoneItemID = GetArchaeologyRaceInfo(raceIndex)
	local artifactName, _, rarity, _, _, numKeystoneSockets = GetSelectedArtifactInfo()

	for index = 1, math.min(numKeystoneSockets, GetItemCount(keystoneItemID)) do
		if(not ItemAddedToArtifact(index)) then
			SocketItemToArtifact()
		end
	end

	local fragments, fragmentsFromKeystones, fragmentsNeeded = GetArtifactProgress()
	if(fragments + fragmentsFromKeystones >= fragmentsNeeded) then
		local color = '|cff9d9d9d'
		if(rarity and rarity > 0) then
			color = '|cff0070dd'
		end

		StaticPopup_Show('ARCHAEOLOGY_SOLVE', string.format('%s %s: %s[%s]|r', SOLVE, raceName, color, artifactName))
	end
end
