local _, addon = ...

local OPTIONS = {
	[123878] = true, -- speed potion in Nerub-ar Palace
	[122627] = true, -- Vaskarn - skip to vendor
}

function addon:GOSSIP_SHOW()
	for _, info in next, C_GossipInfo.GetOptions() do
		if OPTIONS[info.gossipOptionID or 0] then
			C_GossipInfo.SelectOption(info.gossipOptionID)
			break
		end
	end
end
