local _, addon = ...

-- automatically select gossip options

local OPTIONS = {
	-- rogue order hall doors
	[45227] = addon.PLAYER_CLASS == 'ROGUE', -- "Red" Jack Findle
	[45402] = addon.PLAYER_CLASS == 'ROGUE', -- Lucian Trias
	[45145] = addon.PLAYER_CLASS == 'ROGUE', -- Mongar

	-- misc
	[36816] = addon.PLAYER_CLASS == 'HUNTER', -- skip to stable UI
	[123878] = true, -- Nerub-ar Palace - speed
	[122627] = true, -- Vaskarn - skip to vendor
	[125367] = true, -- D.R.I.V.E
}

function addon:GOSSIP_SHOW()
	if IsShiftKeyDown() or InCombatLockdown() then
		return
	end

	for _, option in next, C_GossipInfo.GetOptions() do
		if OPTIONS[option.gossipOptionID or 0] then
			C_GossipInfo.SelectOption(option.gossipOptionID)
			break
		end
	end
end
