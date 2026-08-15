local _, addon = ...

-- automatically filter for current expansion, unless an item is not found it'll expand
-- to all expansions and search again, reverting back to current expansion

local FILTER = Enum.AuctionHouseFilter.CurrentExpansionOnly

addon:HookAddOn('Blizzard_AuctionHouseUI', function()
	AuctionHouseFrame:HookScript('OnShow', function()
		C_Timer.After(0.1, function()
			AuctionHouseFrame.SearchBar.FilterButton:Reset()
			AuctionHouseFrame.SearchBar.FilterButton:ToggleFilter(FILTER)
		end)
	end)
end)

function addon:AUCTION_HOUSE_BROWSE_RESULTS_UPDATED()
	if #C_AuctionHouse.GetBrowseResults() == 0 then
		if AuctionHouseFrame.SearchBar.FilterButton:GetFilters()[FILTER] then
			-- remove filter and search again
			AuctionHouseFrame.SearchBar.FilterButton:ToggleFilter(FILTER)
			AuctionHouseFrame.SearchBar:StartSearch()

			-- reset filter afterwards
			AuctionHouseFrame.SearchBar.FilterButton:ToggleFilter(FILTER)
		end
	end
end
