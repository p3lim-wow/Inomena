local addonName, addon = ...

-- custom rings and bindings

-- semi-smart AIO pet macro because blizzard broke mend+revive
local PET_MACRO = [[
#showtooltip
/cast [@pet,dead] {{spell:982}}
/cast [@pet,exists,nopet:%d] {{spell:2641}}
/cast [@pet,noexists] {{spell:%d}}
/cast [@pet,nodead,exists] {{spell:136}}
]]

local RINGS = addon:T({
	-- class utility rings
	{
		name = addonName .. 'Hunter',
		limit = 'HUNTER',
		hotkey = 'ALT-1',

		-- pet management
		{'imptext', PET_MACRO:format(1, 883), show='[havepet:1]', _t=883},
		{'imptext', PET_MACRO:format(2, 83242), show='[havepet:2]', _t=83242},
		{'imptext', PET_MACRO:format(3, 83243), show='[havepet:3]', _t=83243},
		{'imptext', PET_MACRO:format(4, 83244), show='[havepet:4]', _t=83244},
		{'imptext', PET_MACRO:format(5, 83245), show='[havepet:5]', _t=83245},
		{'spell', 1515, show='[nohavepet:1][nohavepet:2][nohavepet:3][nohavepet:4][nohavepet:5]'}, -- Tame Beast if empty slot
		{'spell', 982, show='[nopet]'}, -- Revive Pet, as a backup in case macro fails
	},
	{
		name = addonName .. 'Warlock',
		limit = 'WARLOCK',
		hotkey = 'ALT-1',

		-- demons
		{'spell', 30146}, -- Felguard
		{'spell', 691}, -- Felhunter
		{'spell', 688}, -- Imp
		{'spell', 697}, -- Voidwalker
		{'spell', 366222}, -- Succubus

		-- add some utility here as well, because why not
		{'spell', 698, show='[group]'}, -- Ritual of Summoning
		{'spell', 6201, show='[nogroup]'}, -- Create Healthstone
		{'spell', 29893, show='[group]'}, -- Soulwell

		-- Fel Domination last so it's in a convenient spot
		{'spell', 333889}, -- Fel Domination
	},
	{
		name = addonName .. 'Rogue',
		limit = 'ROGUE',
		hotkey = 'ALT-1',

		-- lethal poisons
		{'spell', 2823}, -- Deadly Poison (assassination only)
		{'spell', 381664}, -- Amplifying Poison (assassination only)
		{'spell', 315584, show='[nospec:1]'}, -- Instant Poison
		{'spell', 8679}, -- Wound Poison

		-- non-lethal poisons
		{'spell', 5761}, -- Numbing Poison
		{'spell', 381637}, -- Atrophic Poison
		{'spell', 3408}, -- Crippling Poison
	},
	{
		name = addonName .. 'MageTeleport',
		limit = 'MAGE',

		{'spell', 193759}, -- Hall of the Guardian
		{'spell', 1259190}, -- Silvermoon
		{'spell', 446540}, -- Dornogal
		{'spell', 395277}, -- Valdrakken
		{'spell', 344587}, -- Oribos
		{'spell', 281404, show='[horde]'}, -- Dazar'alor
		{'spell', 281403, show='[alliance]'}, -- Boralus
		{'spell', 224869}, -- Dalaran - Broken Isles
		{'spell', 176242, show='[horde]'}, -- Warspear
		{'spell', 176248, show='[alliance]'}, -- Stormshield
		{'spell', 132627, show='[horde]'}, -- Vale of Eternal Blossoms
		{'spell', 132621, show='[alliance]'}, -- Vale of Eternal Blossoms
		{'spell', 88344, show='[horde]'}, -- Tol Barad
		{'spell', 88342, show='[alliance]'}, -- Tol Barad
		{'spell', 53140}, -- Dalaran - Northrend
		{'spell', 35715, show='[horde]'}, -- Shattrath
		{'spell', 33690, show='[alliance]'}, -- Shattrath
		{'spell', 49358, show='[horde]'}, -- Stonard
		{'spell', 49359, show='[alliance]'}, -- Theramore
		{'spell', 3563, show='[horde]'}, -- Undercity
		{'spell', 3562, show='[alliance]'}, -- Ironforge
		{'spell', 3567, show='[horde]'}, -- Orgrimmar
		{'spell', 3561, show='[alliance]'}, -- Stormwind
		{'spell', 3566, show='[horde]'}, -- Thunder Bluff
		{'spell', 3565, show='[alliance]'}, -- Darnassus
		{'spell', 32272, show='[horde]'}, -- Silvermoon
		{'spell', 32271, show='[alliance]'}, -- Exodar
		{'spell', 120145}, -- Ancient Dalaran
	},
	{
		name = addonName .. 'MagePortal',
		limit = 'MAGE',

		{'spell', 1259194}, -- Silvermoon
		{'spell', 446534}, -- Dornogal
		{'spell', 395289}, -- Valdrakken
		{'spell', 344597}, -- Oribos
		{'spell', 281402, show='[horde]'}, -- Dazar'alor
		{'spell', 281400, show='[alliance]'}, -- Boralus
		{'spell', 224871}, -- Dalaran - Broken Isles
		{'spell', 176244, show='[horde]'}, -- Warspear
		{'spell', 176246, show='[alliance]'}, -- Stormshield
		{'spell', 132626, show='[horde]'}, -- Vale of Eternal Blossoms
		{'spell', 132620, show='[alliance]'}, -- Vale of Eternal Blossoms
		{'spell', 88346, show='[horde]'}, -- Tol Barad
		{'spell', 88345, show='[alliance]'}, -- Tol Barad
		{'spell', 53142}, -- Dalaran - Northrend
		{'spell', 35717, show='[horde]'}, -- Shattrath
		{'spell', 33691, show='[alliance]'}, -- Shattrath
		{'spell', 49361, show='[horde]'}, -- Stonard
		{'spell', 49360, show='[alliance]'}, -- Theramore
		{'spell', 11418, show='[horde]'}, -- Undercity
		{'spell', 11416, show='[alliance]'}, -- Ironforge
		{'spell', 11417, show='[horde]'}, -- Orgrimmar
		{'spell', 10059, show='[alliance]'}, -- Stormwind
		{'spell', 11420, show='[horde]'}, -- Thunder Bluff
		{'spell', 11419, show='[alliance]'}, -- Darnassus
		{'spell', 32267, show='[horde]'}, -- Silvermoon
		{'spell', 32266, show='[alliance]'}, -- Exodar
		{'spell', 120146}, -- Ancient Dalaran
	},
	{
		name = addonName .. 'Wormholes',

		{'toy', 248485}, -- Wormhole Generator: Quel'Thalas
		{'toy', 221966}, -- Wormhole Generator: Khaz Algar
		{'toy', 198156}, -- Wyrmhole Generator (Dragonflight)
		{'toy', 172924}, -- Wormhole Generator: Shadowlands
		{'toy', 168807}, -- Wormhole Generator: Kul Tiras
		{'toy', 168808}, -- Wormhole Generator: Zandalar
		{'item', 144341}, -- Rechargeable Reaves Battery (Legion)
		{'toy', 151652}, -- Wormhole Generator: Argus
		{'toy', 112059}, -- Wormhole Centrifuge (Draenor)
		{'toy', 87215}, -- Wormhole Generator: Pandaria
		{'toy', 48933}, -- Wormhole Generator: Northrend
		{'toy', 30542}, -- Dimensional Ripper - Area 52
		{'toy', 30544}, -- Ultrasafe Teleporter: Toshley's Station
		{'toy', 18984}, -- Dimensional Ripper - Everlook
		{'toy', 18986}, -- Ultrasafe Teleporter: Gadgetzan
	},
	{
		name = addonName .. 'Teleport',
		hotkey = 'ALT-G',

		{'ring', 'CommonHearth', fastClick=true, rotationMode='shuffle'},
		{'opie.ext', 'mythport', show='[mythport]', _t='mythport'},
		{'ring', addonName .. 'Wormholes'},

		-- misc toys
		{'toy', 151016}, -- Fractured Necrolyte Skull
		{'toy', 153004}, -- Unstable Portal Emitter
		{'toy', 136849, show='[me:druid]'}, -- Nature's Beacon

		-- class/racial items and spells
		{'spell', 193753, show='[me:druid]'}, -- Dreamwalk
		{'spell', 18960, show='[me:druid]'}, -- Teleport: Moonglade
		{'item', 139590, show='[me:rogue]'}, -- Scroll of Teleport: Ravenholdt
		{'spell', 50977, show='[me:deathknight]'}, -- Death Gate
		{'spell', 312370, show='[race:vulpera]'}, -- Make Camp
		{'spell', 312372, show='[race:vulpera]'}, -- Return to Camp
		{'spell', 126892, show='[me:monk]'}, -- Zen Pilgrimage
		{'spell', 556, show='[me:shaman]'}, -- Astral Recall
		{'spell', 265225}, -- Mole Machine (Dark Iron Dwarf)
		{'ring', addonName .. 'MagePortal', show='[me:mage]'},
		{'ring', addonName .. 'MageTeleport', show='[me:mage]'},

		-- misc items
		{'item', 118662}, -- Bladespire Relic
		{'item', 37863}, -- Direbrew's Remote
		{'item', 128353}, -- Admiral's Compass
		{'toy', 110560}, -- Garrison Hearthstone
		{'toy', 140192}, -- Dalaran Hearthstone
		{'toy', 230850}, -- Delve-O-Bot 7001
		{'toy', 243056, show='[in:world][in:garrison]'}, -- Delver's Mana-Bound Ethergate
		{'item', 219222}, -- Time-Lost Artifact (item variant from 2024 timerunning)

		-- zone-conditional items and toys
		{'toy', 43824, show='[zone:Dalaran]'}, -- The Schools of Arcane Magic - Mastery
		{'toy', 95568, show='[horde,zone:Isle of Thunder][horde,zone:Throne of Thunder]'}, -- Sunreaver Beacon
		{'toy', 95567, show='[alliance,zone:Isle of Thunder][alliance,zone:Throne of Thunder]'}, -- Kirin Tor Beacon
		{'toy', 140324, show='[zone:Suramar]'}, -- Mobile Telemancy Beacon
		{'toy', 169298, show='[horde,zone:Alterac Valley]'}, -- Frostwolf Insignia
		{'toy', 169297, show='[alliance,zone:Alterac Valley]'}, -- Stormpike Insignia
		{'item', 141605, show='[in:Broken Isles/Argus/BfA]'}, -- Flight Master's Whistle
		{'item', 168862, show='[in:Broken Isles/Argus/BfA]'}, -- G.E.A.R. Tracking Beacon
		{'item', 180817, show='[zone:The Maw]'}, -- Cypher of Relocation
		{'toy', 205255, show='[zone:Zaralek Cavern]'}, -- Niffen Diggin' Mitts
		{'item', 234389, show='[zone:Liberation of Undermine]'}, -- Gallagio Royalty Rewards Card: Silver
		{'item', 249699, show='[zone:Manaforge Omega]'}, -- Shadowguard Translocator
		{'item', 217930}, -- Nostwin's Voucher (Timerunning 2024)
		{'item', 238727}, -- Nostwin's Voucher (Timerunning 2025)

		-- custom actions for housing teleportation at the end
		{'inomena.housereturn', show='[house:inside/plot/editor/neighborhood]', _t='housereturn'},
		{'ring', addonName .. 'Home'},
	},
	-- common utility rings
	{
		name = addonName .. 'ExtraMounts',
		hotkey = 'SHIFT-HOME',

		-- the first owned mount with the flag "fastClick" will be the default action
		{'spell', 465235, fastClick=true}, -- Trader's Gilded Brutosaur
		-- {'spell', 264058, fastClick=true}, -- Mighty Caravan Brutosaur
		{'spell', 457485, fastClick=true}, -- Grizzly Hills Packmaster
		-- {'spell', 122708, fastClick=true}, -- Grand Expedition Yak
		-- {'spell', 61447, show='[horde]', fastClick=true}, -- Traveler's Tundra Mammoth (Horde)
		-- {'spell', 61425, show='[alliance]', fastClick=true}, -- Traveler's Tundra Mammoth (Alliance)
		{'spell', 436854}, -- Swift Flight Style
		{'ring', addonName .. 'SwimmingMounts'},
		{'spell', 48778, show='[known:444008]'}, -- Acherus Deathcharger w/"On a Paler Horse" talent
	},
	{
		name = addonName .. 'TradeSkill',
		extends = 'CommonTrades', -- base off of a ring provided by OPie

		-- misc utility that aren't really tradeskills but I like to have them in this ring
		{'spell', 83958}, -- Mobile Banking
		{'spell', 460905}, -- Warband Bank Distance Inhibitor
	},
	{
		name = addonName .. 'SwimmingMounts',
		-- data gets injected later, this ring must be last!
	}
})

do
	local sliceTokens = {}
	local function AddRing(ring)
		if ring.extends then
			-- fork a default ring
			local orig = OPie.CustomRings:GetDefaultDescription(ring.extends)
			local fork = {
				name = ring.name,
				hotkey = ring.hotkey or orig.hotkey,
			}

			-- inject slices from the original
			for _, slice in ipairs(orig) do
				if slice[1] == 'imptext' then
					table.insert(fork, {id=slice[2], _t=slice._u}) -- hopefully unique enough token
				else
					table.insert(fork, slice)
				end
			end

			-- append our slices
			for _, slice in ipairs(ring) do
				table.insert(fork, slice)
			end

			ring = fork
		end

		for _, slice in ipairs(ring) do
			-- OPie requires unique token per slice
			-- https://www.townlong-yak.com/addons/opie/dev/slice-token-requirements
			slice.sliceToken = ring.name .. '_' .. (slice._t or (slice[1] .. (slice[2] or '')))
			slice.sliceToken = slice.sliceToken:gsub('%.', '_') -- token doesn't support "."
			assert(not sliceTokens[slice.sliceToken], 'sliceToken ' .. slice.sliceToken .. ' is not unique')
			sliceTokens[slice.sliceToken] = true
		end

		OPie.CustomRings:SetExternalRing(ring.name, ring)
	end

	function addon:OnLogin()
		-- have to delay this in order to inject swimming mounts
		if addon:IsAddOnEnabled('OPie') then
			-- inject swimming mounts to the last custom ring dynamically based on their existence
			for _, mountID in next, C_MountJournal.GetMountIDs() do
				local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
				if mountType == 231 or mountType == 254 then -- turtle/swimming
					local _, spellID = C_MountJournal.GetMountInfoByID(mountID)
					table.insert(RINGS[RINGS:size()], 1, {'spell', spellID})
				end
			end

			-- add our custom rings
			for _, ring in next, RINGS do
				AddRing(ring)
			end
		end
	end
end

-- kill OPie's default bindings
addon:HookAddOn('OPie', function()
	if not OPie_SavedData then
		OPie_SavedData = {}
	end
	if not OPie_SavedData.ProfileStorage then
		OPie_SavedData.ProfileStorage = {}
	end
	if not OPie_SavedData.ProfileStorage.default then
		OPie_SavedData.ProfileStorage.default = {}
	end
	if not OPie_SavedData.ProfileStorage.default.Bindings then
		OPie_SavedData.ProfileStorage.default.Bindings = {}
	end

	-- ripped out of OPie/Bundle/Editable.lua
	OPie_SavedData.ProfileStorage.default.Bindings.CommonTrades = false
	OPie_SavedData.ProfileStorage.default.Bindings.DKCombat = false
	OPie_SavedData.ProfileStorage.default.Bindings.DruidFeral = false
	OPie_SavedData.ProfileStorage.default.Bindings.DruidShift = false
	OPie_SavedData.ProfileStorage.default.Bindings.DruidUtility = false
	OPie_SavedData.ProfileStorage.default.Bindings.HunterAspects = false
	OPie_SavedData.ProfileStorage.default.Bindings.MageCombat = false
	OPie_SavedData.ProfileStorage.default.Bindings.MageTools = false
	OPie_SavedData.ProfileStorage.default.Bindings.MageTravel = false
	OPie_SavedData.ProfileStorage.default.Bindings.OPieAutoQuest = false
	OPie_SavedData.ProfileStorage.default.Bindings.PaladinTools = false
	OPie_SavedData.ProfileStorage.default.Bindings.RaidSymbols = false
	OPie_SavedData.ProfileStorage.default.Bindings.SpecMenu = false
	OPie_SavedData.ProfileStorage.default.Bindings.WarlockCombat = false
	OPie_SavedData.ProfileStorage.default.Bindings.WarlockLTS = false
	OPie_SavedData.ProfileStorage.default.Bindings.WorldMarkers = false
end)
