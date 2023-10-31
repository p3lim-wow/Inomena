local addonName, addon = ...

local COPPER_PER_SILVER = _G.COPPER_PER_SILVER or 100 -- SharedXML/FormattingUtil.lua
local SILVER_PER_GOLD = _G.SILVER_PER_GOLD or 100 -- SharedXML/FormattingUtil.lua
local COPPER_PER_GOLD = _G.COPPER_PER_GOLD or (COPPER_PER_SILVER * SILVER_PER_GOLD) -- SharedXML/FormattingUtil.lua

local function formatShortMoney(money)
	local output
	output = string.format('|cffffff66%s|r', FormatLargeNumber(math.floor(money / COPPER_PER_GOLD)))
	output = string.format('%s.|cffc0c0c0%02d|r', output, (money / SILVER_PER_GOLD) % COPPER_PER_SILVER)
	output = string.format('%s.|cffcc9900%02d|r', output, money % COPPER_PER_SILVER)
	return output
end

function addon:PLAYER_LOGIN()
	if C_ClassTrial.IsClassTrialCharacter() then
		return
	end

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
	if C_ClassTrial.IsClassTrialCharacter() then
		return
	end

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

local tooltip = addon:CreateButton('Button', addonName .. 'Money', ContainerFrame1MoneyFrame)
tooltip:SetAllPoints()
tooltip:SetFrameStrata('HIGH')
tooltip:SetScript('OnLeave', GameTooltip_Hide)
tooltip:SetScript('OnEnter', function(self)
	GameTooltip:SetOwner(self, 'ANCHOR_NONE')
	GameTooltip:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT')

	local total = 0
	for character, money in orderedPairs(_G.InomenaMoney[GetRealmID()]) do
		if money > 10000 then -- ignore characters with less than 1 gold, they're probably deleted
			local name, class = string.split(':', character)

			local color = C_ClassColor.GetClassColor(class)
			GameTooltip:AddDoubleLine(color:WrapTextInColorCode(name), formatShortMoney(money))

			total = total + money
		end
	end

	GameTooltip:AddLine(' ')
	GameTooltip:AddDoubleLine('Total', formatShortMoney(total))

	GameTooltip:Show()
end)
