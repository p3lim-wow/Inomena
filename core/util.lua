local _, addon = ...

-- safely set boolean(-ish) state on blizzard objects without taint.
-- this is _super_ hacky, but it's the only way we can do this safely
function addon:SafeSetTrue(object, key)
	TextureLoadingGroupMixin.AddTexture({textures = object}, key)
end

function addon:SafeSetNil(object, key)
	TextureLoadingGroupMixin.RemoveTexture({textures = object}, key)
end

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
