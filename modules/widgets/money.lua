local _, addon = ...

function addon:PLAYER_LOGIN()
	if not _G.InomenaMoney then
		_G.InomenaMoney = {}
	end

	local realm = GetRealmID()
	if not _G.InomenaMoney[realm] then
		_G.InomenaMoney[realm] = {}
	end

	local character = UnitName('player') .. ':' .. (UnitClassBase('player'))
	if not _G.InomenaMoney[realm][character] then
		_G.InomenaMoney[realm][character] = GetMoney()
	end
end

function addon:PLAYER_MONEY()
	local character = UnitName('player') .. ':' .. (UnitClassBase('player'))
	_G.InomenaMoney[GetRealmID()][character] = GetMoney()
end

-- I'd go nuts if this data wasn't sorted
-- http://lua-users.org/wiki/SortedIteration
local function orderedNext(tbl)
	-- get the first object in the original table
	local key = tbl[tbl.__next]
	if not key then
		return
	end

	-- update the iterator index
	tbl.__next = tbl.__next + 1

	-- return the key and value of the key in the source table
	return key, tbl.__source[key]
end

local function orderedPairs(tbl)
	local keys = {
		__source = tbl,
		__next = 1,
	}

	-- create an indexed array of the assoc array's keys
	for key in pairs(tbl) do
		table.insert(keys, key)
	end

	-- sort that table
	table.sort(keys)

	-- return a new iterator of using the keys as a map
	return orderedNext, keys
end

local tooltip = addon:CreateButton('Money', ContainerFrame1MoneyFrame)
tooltip:SetAllPoints()
tooltip:SetFrameStrata('HIGH')
tooltip:SetScript('OnLeave', GameTooltip_Hide)
tooltip:SetScript('OnEnter', function(self)
	GameTooltip:SetOwner(self, 'ANCHOR_NONE')
	GameTooltip:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT')

	local total = 0
	for character, money in orderedPairs(_G.InomenaMoney[GetRealmID()]) do
		local name, class = string.split(':', character)

		local color = RAID_CLASS_COLORS[class]
		GameTooltip:AddDoubleLine(color:WrapTextInColorCode(name), addon:FormatShortMoney(money))

		total = total + money
	end

	GameTooltip:AddLine(' ')
	GameTooltip:AddDoubleLine('Total', addon:FormatShortMoney(total))

	GameTooltip:Show()
end)
