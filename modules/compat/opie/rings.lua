local addonName, addon = ...

local RINGS = {
	{
		name = 'Mage Teleport',
		limit = 'MAGE',

		{'spell', 193759, c='d000ff'},                    -- Hall of the Guardian
		{'spell', 344587, c='209fe6'},                    -- Oribos
		{'spell', 281404, c='f9e222', show='[horde]'},    -- Dazar'alor
		{'spell', 281403, c='21d2d5', show='[alliance]'}, -- Boralus
		{'spell', 224869, c='83ff61'},                    -- Dalaran - Broken Isles
		{'spell', 176242, c='00abf0', show='[horde]'},    -- Warspear
		{'spell', 176248, c='f03000', show='[alliance]'}, -- Stormshield
		{'spell', 132627, c='ffc34d', show='[horde]'},    -- Vale of Eternal Blossoms
		{'spell', 132621, c='ffc34d', show='[alliance]'}, -- Vale of Eternal Blossoms
		{'spell', 88344,  c='f03c00', show='[horde]'},    -- Tol Barad
		{'spell', 88342,  c='f03c00', show='[alliance]'}, -- Tol Barad
		{'spell', 53140,  c='a54cff'},                    -- Dalaran - Northrend
		{'spell', 35715,  c='4dffc3', show='[horde]'},    -- Shattrath
		{'spell', 33690,  c='4dffc3', show='[alliance]'}, -- Shattrath
		{'spell', 49358,  c='b0ff26', show='[horde]'},    -- Stonard
		{'spell', 49359,  c='f09d00', show='[alliance]'}, -- Theramore
		{'spell', 3563,   c='77ff4d', show='[horde]'},    -- Undercity
		{'spell', 3562,   c='4cddff', show='[alliance]'}, -- Ironforge
		{'spell', 3567,   c='ff8126', show='[horde]'},    -- Orgrimmar
		{'spell', 3561,   c='0d54f0', show='[alliance]'}, -- Stormwind
		{'spell', 3566,   c='4cddff', show='[horde]'},    -- Thunder Bluff
		{'spell', 3565,   c='9d0df0', show='[alliance]'}, -- Darnassus
		{'spell', 32272,  c='f00e00', show='[horde]'},    -- Silvermoon
		{'spell', 32271,  c='f024e2', show='[alliance]'}, -- Exodar
		{'spell', 120145, c='a54cff'},                    -- Ancient Dalaran
	},
	{
		name = 'Mage Portal',
		limit = 'MAGE',

		{'spell', 193759, c='d000ff'},                    -- Hall of the Guardian (just for symmetry)
		{'spell', 344597, c='209fe6'},                    -- Oribos
		{'spell', 281402, c='f9e222', show='[horde]'},    -- Dazar'alor
		{'spell', 281400, c='21d2d5', show='[alliance]'}, -- Boralus
		{'spell', 224871, c='83ff61'},                    -- Dalaran - Broken Isles
		{'spell', 176244, c='00abf0', show='[horde]'},    -- Warspear
		{'spell', 176246, c='f03000', show='[alliance]'}, -- Stormshield
		{'spell', 132626, c='ffc34d', show='[horde]'},    -- Vale of Eternal Blossoms
		{'spell', 132620, c='ffc34d', show='[alliance]'}, -- Vale of Eternal Blossoms
		{'spell', 88346,  c='f03c00', show='[horde]'},    -- Tol Barad
		{'spell', 88345,  c='f03c00', show='[alliance]'}, -- Tol Barad
		{'spell', 53142,  c='a54cff'},                    -- Dalaran - Northrend
		{'spell', 35717,  c='4dffc3', show='[horde]'},    -- Shattrath
		{'spell', 33691,  c='4dffc3', show='[alliance]'}, -- Shattrath
		{'spell', 49361,  c='b0ff26', show='[horde]'},    -- Stonard
		{'spell', 49360,  c='f09d00', show='[alliance]'}, -- Theramore
		{'spell', 11418,  c='77ff4d', show='[horde]'},    -- Undercity
		{'spell', 11416,  c='4cddff', show='[alliance]'}, -- Ironforge
		{'spell', 11417,  c='ff8126', show='[horde]'},    -- Orgrimmar
		{'spell', 10059,  c='0d54f0', show='[alliance]'}, -- Stormwind
		{'spell', 11420,  c='4cddff', show='[horde]'},    -- Thunder Bluff
		{'spell', 11419,  c='9d0df0', show='[alliance]'}, -- Darnassus
		{'spell', 32267,  c='f00e00', show='[horde]'},    -- Silvermoon
		{'spell', 32266,  c='f024e2', show='[alliance]'}, -- Exodar
		{'spell', 120146, c='a54cff'},                    -- Ancient Dalaran
	},
}

local function addRing(data)
	local id = addonName .. data.name:gsub(' ', '')
	OPie.CustomRings:SetExternalRing(id, data)
end

addon:HookAddOn('OPie', function()
	for _, ring in next, RINGS do
		addRing(ring)
	end
end)
