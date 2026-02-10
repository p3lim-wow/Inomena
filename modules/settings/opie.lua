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
		name = addonName .. 'Paladin',
		limit = 'PALADIN',
		hotkey = 'ALT-1',

		-- auras
		{'spell', 465}, -- Devotion Aura
		{'spell', 317920}, -- Concentration Aura
		{'spell', 32223}, -- Crusader Aura
	},
	-- (hidden) expansion/continent teleport rings
	{
		name = addonName .. 'Teleport12', -- Midnight

		{'spell', 1259190, show='[me:mage]'}, -- Teleport: Silvermoon
		{'spell', 1259194, show='[me:mage]'}, -- Portal: Silvermoon
		{'toy', 248485}, -- Wormhole Generator: Quel'Thalas
		{'spell', 1254400}, -- Path of the Windrunners (Windrunner Spire)
		{'spell', 1254559}, -- Path of Cavernous Depths (Maisara Caverns)
		{'spell', 1254563}, -- Path of the Fractured Core (Nexus-Point Xenas)
		{'spell', 1254572}, -- Path of Devoted Magistry (Magisters' Terrace)
	},
	{
		name = addonName .. 'Teleport11', -- Khaz Algar

		{'spell', 446540, show='[me:mage]'}, -- Teleport: Dornogal
		{'spell', 446534, show='[me:mage]'}, -- Portal: Dornogal
		{'toy', 221966}, -- Wormhole Generator: Khaz Algar
		{'toy', 243056, show='[in:world][in:garrison]'}, -- Delver's Mana-Bound Ethergate
		{'toy', 230850, show='[in:world][in:garrison]'}, -- Delve-O-Bot 7001
		{'spell', 1216786}, -- Path of the Circuit Breaker (Operation: Floodgate)
		{'spell', 367416}, -- Path of the Streetwise Merchant (Tazavesh, the Veiled Market)
		{'spell', 445269}, -- Path of the Corrupted Foundry (The Stonevault)
		{'spell', 445414}, -- Path of the Arathi Flagship (The Dawnbreaker)
		{'spell', 445416}, -- Path of Nerubian Ascension (City of Threads)
		{'spell', 445417}, -- Path of the Ruined City (Ara-Kara, City of Echoes)
		{'spell', 445440}, -- Path of the Flaming Brewery (Cinderbrew Meadery)
		{'spell', 445441}, -- Path of the Warding Candles (Darkflame Cleft)
		{'spell', 445443}, -- Path of the Fallen Stormriders (The Rookery)
		{'spell', 445444}, -- Path of the Light's Reverence (Priory of the Sacred Flame)
		{'spell', 1237215}, -- Path of the Eco-Dome (Eco-Dome Al'dani)
		{'spell', 1226482}, -- Path of the Full House (Liberation of Undermine)
		{'spell', 1239155}, -- Path of the All-Devouring (Manaforge Omega)
	},
	{
		name = addonName .. 'Teleport10', -- Dragon Isles

		{'spell', 395277, show='[me:mage]'}, -- Teleport: Valdrakken
		{'spell', 395289, show='[me:mage]'}, -- Portal: Valdrakken
		{'toy', 198156}, -- Wyrmhole Generator (Dragonflight)
		{'item', 200613}, -- Aylaag Windstone Fragment
		{'item', 204481}, -- Morqut Hearth Totem
		{'spell', 393256}, -- Path of the Clutch Defender (Ruby Life Pools)
		{'spell', 393262}, -- Path of the Windswept Plains (The Nokhud Offensive)
		{'spell', 393267}, -- Path of the Rotting Woods (Brackenhide Hollow)
		{'spell', 393273}, -- Path of the Draconic Diploma (Algeth'ar Academy)
		{'spell', 393276}, -- Path of the Obsidian Hoard (Neltharus)
		{'spell', 393279}, -- Path of Arcane Secrets (The Azure Vault)
		{'spell', 393283}, -- Path of the Titanic Reservoir (Halls of Infusion)
		{'spell', 424197}, -- Path of Twisted Time (Dawn of the Infinite)
		{'spell', 432254}, -- Path of the Primal Prison (Vault of the Incarnates)
		{'spell', 432257}, -- Path of the Bitter Legacy (Aberrus, the Shadowed Crucible)
		{'spell', 432258}, -- Path of the Scorching Dream (Amirdrassil, the Dream's Hope)
	},
	{
		name = addonName .. 'Teleport9', -- Shadowlands

		{'spell', 344587, show='[me:mage]'}, -- Teleport: Oribos
		{'spell', 344597, show='[me:mage]'}, -- Portal: Oribos
		{'toy', 172924}, -- Wormhole Generator: Shadowlands
		{'item', 181163}, -- Scroll of Teleport: Theater of Pain
		{'item', 184500}, -- Attendant's Pocket Portal: Bastion
		{'item', 184501}, -- Attendant's Pocket Portal: Revendreth
		{'item', 184502}, -- Attendant's Pocket Portal: Maldraxxus
		{'item', 184503}, -- Attendant's Pocket Portal: Ardenweald
		{'item', 184504}, -- Attendant's Pocket Portal: Oribos
		{'spell', 354462}, -- Path of the Courageous (The Necrotic Wake)
		{'spell', 354463}, -- Path of the Plagued (Plaguefall)
		{'spell', 354464}, -- Path of the Misty Forest (Mists of Tirna Scithe)
		{'spell', 354465}, -- Path of the Sinful Soul (Halls of Atonement)
		{'spell', 354466}, -- Path of the Ascendant (Spires of Ascension)
		{'spell', 354467}, -- Path of the Undefeated (Theater of Pain)
		{'spell', 354468}, -- Path of the Scheming Loa (De Other Side)
		{'spell', 354469}, -- Path of the Stone Warden (Sanguine Depths)
		{'spell', 373190}, -- Path of the Sire (Castle Nathria)
		{'spell', 373191}, -- Path of the Tormented Soul (Sanctum of Domination)
		{'spell', 373192}, -- Path of the First Ones (Sepulcher of the First Ones)
	},
	{
		name = addonName .. 'Teleport8', -- Zandalar & Kul Tiras

		{'spell', 281404, show='[me:mage,horde]'}, -- Teleport: Dazar'alor
		{'spell', 281402, show='[me:mage,horde]'}, -- Portal: Dazar'alor
		{'spell', 281403, show='[me:mage,alliance]'}, -- Teleport: Boralus
		{'spell', 281400, show='[me:mage,alliance]'}, -- Portal: Boralus
		{'toy', 168807}, -- Wormhole Generator: Kul Tiras
		{'toy', 168808}, -- Wormhole Generator: Zandalar
		{'item', 166559}, -- Commander's Signet of Battle
		{'item', 166560}, -- Captain's Signet of Command
		{'item', 202046}, -- Lucky Tortollan Charm
		{'item', 167075}, -- Ultrasafe Transporter: Mechagon
		{'spell', 373274}, -- Path of the Scrappy Prince (Operation: Mechagon)
		{'spell', 410071}, -- Path of the Freebooter (Freehold)
		{'spell', 410074}, -- Path of Festering Rot (The Underrot)
		{'spell', 424167}, -- Path of Heart's Bane (Waycrest Manor)
		{'spell', 424187}, -- Path of the Golden Tomb (Atal'Dazar)
		{'spell', 445418, show='[alliance]'}, -- Path of the Besieged Harbor (Siege of Boralus) (alliance version)
		{'spell', 464256, show='[horde]'}, -- Path of the Besieged Harbor (Siege of Boralus) (horde version)
		{'spell', 467553, show='[alliance]'}, -- Path of the Azerite Refinery (The MOTHERLODE!!) (alliance version)
		{'spell', 467555, show='[horde]'}, -- Path of the Azerite Refinery (The MOTHERLODE!!) (horde version)
	},
	{
		name = addonName .. 'Teleport7', -- Broken Isles

		{'toy', 140192}, -- Dalaran Hearthstone
		{'spell', 193753, show='[me:druid]'}, -- Dreamwalk
		{'spell', 50977, show='[me:deathknight]'}, -- Death Gate
		{'spell', 193759, show='[me:mage]'}, -- Teleport: Hall of the Guardian
		{'spell', 224869, show='[me:mage]'}, -- Teleport: Dalaran - Broken Isles
		{'spell', 224871, show='[me:mage]'}, -- Portal: Dalaran - Broken Isles
		{'item', 144341}, -- Rechargeable Reaves Battery
		{'toy', 151652}, -- Wormhole Generator: Argus
		{'item', 140493}, -- Adept's Guide to Dimensional Rifting
		{'item', 141013}, -- Scroll of Town Portal: Shala'nir
		{'item', 141014}, -- Scroll of Town Portal: Sashj'tar
		{'item', 141015}, -- Scroll of Town Portal: Kal'delar
		{'item', 141016}, -- Scroll of Town Portal: Faronaar
		{'item', 141017}, -- Scroll of Town Portal: Lian'tril
		{'spell', 393764}, -- Path of Proven Worth (Halls of Valor)
		{'spell', 393766}, -- Path of the Grand Magistrix (Court of Stars)
		{'spell', 410078}, -- Path of the Earth-Warder (Neltharion's Lair)
		{'spell', 424153}, -- Path of Ancient Horrors (Black Rook Hold)
		{'spell', 424163}, -- Path of the Nightmare Lord (Darkheart Thicket)
		{'spell', 1254551}, -- Path of Dark Dereliction (Seat of the Triumvirate)
	},
	{
		name = addonName .. 'Teleport6', -- Draenor

		{'toy', 110560}, -- Garrison Hearthstone
		{'spell', 176242, show='[me:mage,horde]'}, -- Teleport: Warspear
		{'spell', 176244, show='[me:mage,horde]'}, -- Portal: Warspear
		{'spell', 176248, show='[me:mage,alliance]'}, -- Teleport: Stormshield
		{'spell', 176246, show='[me:mage,alliance]'}, -- Portal: Stormshield
		{'toy', 112059}, -- Wormhole Centrifuge (Draenor)
		{'item', 128353}, -- Admiral's Compass
		{'item', 118662}, -- Bladespire Relic
		{'item', 118663}, -- Relic of Karabor
		{'spell', 159895}, -- Path of the Bloodmaul (Bloodmaul Slag Mines)
		{'spell', 159896}, -- Path of the Iron Prow (Iron Docks)
		{'spell', 159897}, -- Path of the Vigilant (Auchindoun)
		{'spell', 159899}, -- Path of the Crescent Moon (Shadowmoon Burial Grounds)
		{'spell', 159900}, -- Path of the Dark Rail (Grimrail Depot)
		{'spell', 159901}, -- Path of the Verdant (The Everbloom)
		{'spell', 159898}, -- Path of the Skies (Skyreach)
		{'spell', 1254557, show='[noknown:159898]'}, -- Path of the Crowning Pinnacle (Skyreach) (avoid duplicates)
	},
	{
		name = addonName .. 'Teleport5', -- Pandaria

		{'spell', 126892, show='[me:monk]'}, -- Zen Pilgrimage
		{'spell', 132627, show='[me:mage,horde]'}, -- Teleport: Vale of Eternal Blossoms
		{'spell', 132626, show='[me:mage,horde]'}, -- Portal: Vale of Eternal Blossoms
		{'spell', 132621, show='[me:mage,alliance]'}, -- Teleport: Vale of Eternal Blossoms
		{'spell', 132620, show='[me:mage,alliance]'}, -- Portal: Vale of Eternal Blossoms
		{'toy', 87215}, -- Wormhole Generator: Pandaria
		{'item', 219222}, -- Time-Lost Artifact (item variant from 2024 timerunning)
		{'item', 103678}, -- Time-Lost Artifact
		{'spell', 131204}, -- Path of the Jade Serpent (Temple of the Jade Serpent)
		{'spell', 131205}, -- Path of the Stout Brew (Stormstout Brewery)
		{'spell', 131206}, -- Path of the Shado-Pan (Shado-Pan Monastery)
		{'spell', 131222}, -- Path of the Mogu King (Mogu'shan Palace)
		{'spell', 131225}, -- Path of the Setting Sun (Gate of the Setting Sun)
		{'spell', 131228}, -- Path of the Black Ox (Siege of Niuzao Temple)
	},
	{
		name = addonName .. 'Teleport3', -- Northrend

		{'spell', 53140, show='[me:mage]'}, -- Teleport: Dalaran - Northrend
		{'spell', 53142, show='[me:mage]'}, -- Portal: Dalaran - Northrend
		{'toy', 48933}, -- Wormhole Generator: Northrend
		{'item', 40585}, -- Signet of the Kirin Tor
		{'item', 40586}, -- Band of the Kirin Tor
		{'item', 44934}, -- Loop of the Kirin Tor
		{'item', 44935}, -- Ring of the Kirin Tor
		{'item', 45688}, -- Inscribed Band of the Kirin Tor
		{'item', 45689}, -- Inscribed Loop of the Kirin Tor
		{'item', 45690}, -- Inscribed Ring of the Kirin Tor
		{'item', 45691}, -- Inscribed Signet of the Kirin Tor
		{'item', 48954}, -- Etched Band of the Kirin Tor
		{'item', 48955}, -- Etched Loop of the Kirin Tor
		{'item', 48956}, -- Etched Ring of the Kirin Tor
		{'item', 48957}, -- Etched Signet of the Kirin Tor
		{'item', 51557}, -- Runed Signet of the Kirin Tor
		{'item', 51558}, -- Runed Loop of the Kirin Tor
		{'item', 51559}, -- Runed Ring of the Kirin Tor
		{'item', 51560}, -- Runed Band of the Kirin Tor
		{'item', 139599}, -- Empowered Ring of the Kirin Tor
		{'item', 46874}, -- Argent Crusader's Tabard
		{'item', 52251}, -- Jaina's Locket
		{'spell', 1254555}, -- Path of Unyielding Blight (Pit of Saron)
	},
	{
		name = addonName .. 'Teleport2', -- Outland

		{'spell', 35715, show='[me:mage,horde]'}, -- Teleport: Shattrath
		{'spell', 35717, show='[me:mage,horde]'}, -- Portal: Shattrath
		{'spell', 33690, show='[me:mage,alliance]'}, -- Teleport: Shattrath
		{'spell', 33691, show='[me:mage,alliance]'}, -- Portal: Shattrath
		{'toy', 30542}, -- Dimensional Ripper - Area 52
		{'toy', 30544}, -- Ultrasafe Teleporter: Toshley's Station
		{'item', 32757}, -- Blessed Medallion of Karabor
		{'toy', 151016}, -- Fractured Necrolyte Skull
	},
	{
		name = addonName .. 'Teleport1', -- Azeroth (incl Cataclysm zones)

		{'spell', 3567, show='[me:mage,horde]'}, -- Teleport: Orgrimmar
		{'spell', 11417, show='[me:mage,horde]'}, -- Portal: Orgrimmar
		{'spell', 3561, show='[me:mage,alliance]'}, -- Teleport: Stormwind
		{'spell', 10059, show='[me:mage,alliance]'}, -- Portal: Stormwind
		{'spell', 3563, show='[me:mage,horde]'}, -- Teleport: Undercity
		{'spell', 11418, show='[me:mage,horde]'}, -- Portal: Undercity
		{'spell', 3562, show='[me:mage,alliance]'}, -- Teleport: Ironforge
		{'spell', 11416, show='[me:mage,alliance]'}, -- Portal: Ironforge
		{'spell', 3566, show='[me:mage,horde]'}, -- Teleport: Thunder Bluff
		{'spell', 11420, show='[me:mage,horde]'}, -- Portal: Thunder Bluff
		{'spell', 3565, show='[me:mage,alliance]'}, -- Teleport: Darnassus
		{'spell', 11419, show='[me:mage,alliance]'}, -- Portal: Darnassus
		{'spell', 32272, show='[me:mage,horde]'}, -- Teleport: Silvermoon
		{'spell', 32267, show='[me:mage,horde]'}, -- Portal: Silvermoon
		{'spell', 32271, show='[me:mage,alliance]'}, -- Teleport: Exodar
		{'spell', 32266, show='[me:mage,alliance]'}, -- Portal: Exodar
		{'spell', 49358, show='[me:mage,horde]'}, -- Teleport: Stonard
		{'spell', 49361, show='[me:mage,horde]'}, -- Portal: Stonard
		{'spell', 49359, show='[me:mage,alliance]'}, -- Teleport: Theramore
		{'spell', 49360, show='[me:mage,alliance]'}, -- Portal: Theramore
		{'spell', 88344, show='[me:mage,horde]'}, -- Teleport: Tol Barad
		{'spell', 88346, show='[me:mage,horde]'}, -- Portal: Tol Barad
		{'spell', 88342, show='[me:mage,alliance]'}, -- Teleport: Tol Barad
		{'spell', 88345, show='[me:mage,alliance]'}, -- Portal: Tol Barad
		{'spell', 120145, show='[me:mage]'}, -- Teleport: Ancient Dalaran
		{'spell', 120146, show='[me:mage]'}, -- Portal: Ancient Dalaran
		{'item', 65274}, -- Cloak of Cooperation (Horde)
		{'item', 63207}, -- Wrap of Unity (Horde)
		{'item', 63353}, -- Shroud of Cooperation (Horde)
		{'item', 65360}, -- Cloak of Cooperation (Alliance)
		{'item', 63206}, -- Wrap of Unity (Alliance)
		{'item', 63352}, -- Shroud of Cooperation (Alliance)
		{'spell', 18960, show='[me:druid]'}, -- Teleport: Moonglade
		{'item', 139590, show='[me:rogue]'}, -- Scroll of Teleport: Ravenholdt
		{'toy', 211788, show='[race:worgen]'}, -- Tess's Peacebloom
		{'item', 50287}, -- Boots of the Bay
		{'toy', 18984}, -- Dimensional Ripper - Everlook
		{'toy', 18986}, -- Ultrasafe Teleporter: Gadgetzan
		{'item', 37863}, -- Direbrew's Remote
		{'item', 63378}, -- Hellscream's Reach Tabard
		{'item', 63379}, -- Baradin Wardens Tabard
		{'item', 142469}, -- Violet Seal of the Grand Magus
		{'item', 22589}, -- Atiesh, Greatstaff of the Guardian (Mage)
		{'item', 22630}, -- Atiesh, Greatstaff of the Guardian (Warlock)
		{'item', 22631}, -- Atiesh, Greatstaff of the Guardian (Priest)
		{'item', 22632}, -- Atiesh, Greatstaff of the Guardian (Druid)
		{'item', 95050}, -- The Brassiest Knuckle (Horde)
		{'item', 95051}, -- The Brassiest Knuckle (Alliance)
		{'item', 118908}, -- Pit Fighter's Punching Ring (Horde)
		{'item', 118907}, -- Pit Fighter's Punching Ring (Alliance)
		{'item', 144391}, -- Pugilist's Powerful Punching Ring (Alliance)
		{'item', 144392}, -- Pugilist's Powerful Punching Ring (Horde)
		{'item', 58487}, -- Potion of Deepholm
		{'spell', 131229}, -- Path of the Scarlet Mitre (Scarlet Monastery)
		{'spell', 131231}, -- Path of the Scarlet Blade (Scarlet Halls)
		{'spell', 131232}, -- Path of the Necromancer (Scholomance)
		{'spell', 159902}, -- Path of the Burning Mountain (Upper Blackrock Spire)
		{'spell', 393222}, -- Path of the Watcher's Legacy (Uldaman: Legacy of Tyr)
		{'spell', 410080}, -- Path of Wind's Domain (The Vortex Pinnacle)
		{'spell', 424142}, -- Path of the Tidehunter (Throne of the Tides)
		{'spell', 445424}, -- Path of the Twilight Fortress (Grim Batol)
		{'spell', 373262}, -- Path of the Fallen Guardian (Karazhan)
	},
	-- combined teleport ring
	{
		name = addonName .. 'Teleport',
		hotkey = 'ALT-G',

		-- most convenient rings first
		{'ring', 'CommonHearth', fastClick=true, rotationMode='shuffle'},
		{'spell', 556, show='[me:shaman]'}, -- Astral Recall
		{'opie.ext', 'mythport', show='[mythport]'}, -- dynamic Hero's Path teleport

		-- continent/expansion specific rings
		{'ring', addonName .. 'Teleport12'},
		{'ring', addonName .. 'Teleport11'},
		{'ring', addonName .. 'Teleport10'},
		{'ring', addonName .. 'Teleport9'},
		{'ring', addonName .. 'Teleport8'},
		{'ring', addonName .. 'Teleport7'},
		{'ring', addonName .. 'Teleport6'},
		{'ring', addonName .. 'Teleport5'},
		{'ring', addonName .. 'Teleport3'},
		{'ring', addonName .. 'Teleport2'},
		{'ring', addonName .. 'Teleport1'},

		-- misc location/race-specific stuff
		{'toy', 169298, show='[zone:Alterac Valley,in:battleground]'}, -- Frostwolf Insignia
		{'item', 17690, show='[zone:Alterac Valley,in:battleground]'}, -- Frostwolf Insignia Rank 1
		{'item', 17905, show='[zone:Alterac Valley,in:battleground]'}, -- Frostwolf Insignia Rank 2
		{'item', 17906, show='[zone:Alterac Valley,in:battleground]'}, -- Frostwolf Insignia Rank 3
		{'item', 17907, show='[zone:Alterac Valley,in:battleground]'}, -- Frostwolf Insignia Rank 4
		{'item', 17908, show='[zone:Alterac Valley,in:battleground]'}, -- Frostwolf Insignia Rank 5
		{'item', 17909, show='[zone:Alterac Valley,in:battleground]'}, -- Frostwolf Insignia Rank 6
		{'toy', 169297, show='[zone:Alterac Valley,in:battleground]'}, -- Stormpike Insignia
		{'item', 17691, show='[zone:Alterac Valley,in:battleground]'}, -- Stormpike Insignia Rank 1
		{'item', 17900, show='[zone:Alterac Valley,in:battleground]'}, -- Stormpike Insignia Rank 2
		{'item', 17901, show='[zone:Alterac Valley,in:battleground]'}, -- Stormpike Insignia Rank 3
		{'item', 17902, show='[zone:Alterac Valley,in:battleground]'}, -- Stormpike Insignia Rank 4
		{'item', 17903, show='[zone:Alterac Valley,in:battleground]'}, -- Stormpike Insignia Rank 5
		{'item', 17904, show='[zone:Alterac Valley,in:battleground]'}, -- Stormpike Insignia Rank 6
		{'toy', 95568, show='[horde,zone:Isle of Thunder][horde,zone:Throne of Thunder]'}, -- Sunreaver Beacon
		{'toy', 95567, show='[alliance,zone:Isle of Thunder][alliance,zone:Throne of Thunder]'}, -- Kirin Tor Beacon
		{'item', 128503, show='[zone:Tanaan Jungle]'}, -- Master Hunter's Seeking Crystal
		{'item', 128502, show='[zone:Tanaan Jungle]'}, -- Hunter's Seeking Crystal
		{'item', 141605, show='[in:Broken Isles/Argus/BfA]'}, -- Flight Master's Whistle
		{'item', 168862, show='[in:Broken Isles/Argus/BfA]'}, -- G.E.A.R. Tracking Beacon
		{'item', 129276, show='[zone:Azsuna]'}, -- Beginner's Guide to Dimensional Rifting
		{'toy', 43824, show='[zone:Dalaran]'}, -- The Schools of Arcane Magic - Mastery
		{'toy', 140324, show='[zone:Suramar]'}, -- Mobile Telemancy Beacon
		{'item', 180817, show='[zone:The Maw]'}, -- Cypher of Relocation
		{'toy', 205255, show='[zone:Zaralek Cavern]'}, -- Niffen Diggin' Mitts
		{'item', 234389, show='[zone:Liberation of Undermine]'}, -- Gallagio Royalty Rewards Card: Silver
		{'item', 249699, show='[zone:Manaforge Omega]'}, -- Shadowguard Translocator
		{'spell', 312370, show='[race:vulpera]'}, -- Make Camp
		{'spell', 312372, show='[race:vulpera]'}, -- Return to Camp
		{'spell', 265225, show='[race:darkirondwarf]'}, -- Mole Machine (Dark Iron Dwarf)
		{'item', 217930}, -- Nostwin's Voucher (Timerunning 2024)
		{'item', 238727}, -- Nostwin's Voucher (Timerunning 2025)

		-- custom actions for housing teleportation at the end
		{'inomena.housereturn', show='[house:inside/plot/editor/neighborhood]'},
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
