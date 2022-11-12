local _, addon = ...

-- automatically open doors to the rogue class hall in Dalaran

local rogueClassHallGossipIDs = {
	[45227] = true, -- "Red" Jack Findle
	[45402] = true, -- Lucian Trias
	[45145] = true, -- Mongar
}

function addon:GOSSIP_SHOW()
	for _, gossipInfo in next, C_GossipInfo.GetOptions() do
		if rogueClassHallGossipIDs[gossipInfo.gossipID] and not IsShiftKeyDown() then
			C_GossipInfo.SelectOption(gossipInfo.gossipID)
			return
		end
	end
end
