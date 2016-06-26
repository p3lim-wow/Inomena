local E, F, C = unpack(select(2, ...))

if(C.playerClass ~= 'ROGUE' or not C.isBetaClient) then
	return
end

local function GetNPCID()
	return tonumber(string.match(UnitGUID('npc') or '', 'Creature%-.-%-.-%-.-%-.-%-(.-)%-'))
end

local secretNPCs = {
	[97004] = true, -- "Red" Jack Findle
	[96782] = true, -- Lucian Trias
}

function E:GOSSIP_SHOW()
	if(not IsShiftKeyDown() and secretNPCs[GetNPCID()]) then
		SelectGossipOption(1)
	end
end
