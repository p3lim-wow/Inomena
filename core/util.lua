local _, addon = ...

do
	local SCALE = 768 / select(2, GetPhysicalScreenSize())
	function addon:PixelPerfect(obj)
		if obj.SetTexelSnappingBias then
			obj:SetTexelSnappingBias(0)
			obj:SetSnapToPixelGrid(false)
		elseif obj.GetObjectType then
			obj:SetIgnoreParentScale(true)
			obj:SetScale(SCALE)
		end
	end
end

function addon:IsHalloween()
	local date = C_DateAndTime.GetCurrentCalendarTime()
	if not date or date.year == 1999 then
		-- on PTR this API can yield invalid data, with year set to 1999
		return false
	end

	local dateNum = tonumber(string.format('%02d%02d%02d', date.month, date.monthDay, date.hour))
	return dateNum >= 101810 and dateNum <= 110111
end

do
	local inDungeon, inRaid

	local DUNGEON_INSTANCE_TYPES = {
		scenario = true,
		party = true,
		raid = true,
	}

	addon:RegisterEvent('PLAYER_ENTERING_WORLD', function()
		local _, instanceType = GetInstanceInfo()
		inDungeon = DUNGEON_INSTANCE_TYPES[instanceType]
		inRaid = instanceType == 'raid'
	end)

	function addon:IsInDungeon()
		return inDungeon
	end

	function addon:IsInRaid()
		return inRaid
	end
end

do
	local abbreviateConfig = {
		breakpointData = {
			{ -- billions
				breakpoint = 1e9,
				abbreviation = 'b',
				significandDivisor = 1e6,
				fractionDivisor = 1e3,
				abbreviationIsGlobal = false,
			},
			{ -- millions
				breakpoint = 1e6,
				abbreviation = 'm',
				significandDivisor = 1e4,
				fractionDivisor = 100,
				abbreviationIsGlobal = false,
			},
			{ -- thousands
				breakpoint = 1e4,
				abbreviation = 'k',
				significandDivisor = 100,
				fractionDivisor = 10,
				abbreviationIsGlobal = false,
			},
		},
	}

	function addon:AbbreviateNumbers(value)
		return AbbreviateNumbers(value, abbreviateConfig)
	end
end

do
	local function inject(list, spellData)
		for spellID, dispelTypes in next, spellData do
			if C_SpellBook.IsSpellKnown(spellID) then
				for dispelType, requiredSpellID in next, dispelTypes do
					if type(requiredSpellID) == 'number' then
						if C_SpellBook.IsSpellKnown(requiredSpellID) then
							list[dispelType] = true
						end
					else
						list[dispelType] = true
					end
				end
			end
		end
	end

	local dispelTypes = {} -- intentionally use a normal table here
	function addon:GetDispelTypes(kind, includePlayerOnly)
		table.wipe(dispelTypes)

		if kind == 'HELPFUL' then
			if addon.RACE_HELPFUL_DISPEL_SPELLS[addon.PLAYER_RACE] then
				inject(dispelTypes, addon.RACE_HELPFUL_DISPEL_SPELLS[addon.PLAYER_RACE])
			end

			if addon.CLASS_HELPFUL_DISPEL_SPELLS[addon.PLAYER_CLASS] then
				inject(dispelTypes, addon.CLASS_HELPFUL_DISPEL_SPELLS[addon.PLAYER_CLASS])
			end
		elseif kind == 'HARMFUL' then
			if addon.CLASS_HARMFUL_DISPEL_SPELLS[addon.PLAYER_CLASS] then
				inject(dispelTypes, addon.CLASS_HARMFUL_DISPEL_SPELLS[addon.PLAYER_CLASS])
			end

			if includePlayerOnly then
				if addon.RACE_HARMFUL_DISPEL_SPELLS[addon.PLAYER_RACE] then
					inject(dispelTypes, addon.RACE_HARMFUL_DISPEL_SPELLS[addon.PLAYER_RACE])
				end

				if addon.CLASS_HARMFUL_DISPEL_SELF_SPELLS[addon.PLAYER_CLASS] then
					inject(dispelTypes, addon.CLASS_HARMFUL_DISPEL_SELF_SPELLS[addon.PLAYER_CLASS])
				end
			end
		end

		return dispelTypes
	end
end

function addon:ResizePillsToFit(pills, numPills, spacing)
	local maxWidth = math.floor(pills:GetWidth())
	local barWidth = math.floor((maxWidth / numPills) - (spacing or addon.SPACING) + ((spacing or addon.SPACING) / numPills))
	local leftover = maxWidth - ((barWidth * numPills) + ((spacing or addon.SPACING) * (numPills - 1)))

	for index = 1, numPills do
		if leftover > (numPills - index) then
			pills[index]:SetWidth(barWidth + 1)
		else
			pills[index]:SetWidth(barWidth)
		end
	end
end
