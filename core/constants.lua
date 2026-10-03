local _, addon = ...

addon.SPACING = 5

addon.PLAYER_CLASS = UnitClassBase('player')
addon.PLAYER_RACE = select(3, UnitRace('player'))
addon.PLAYER_FACTION = UnitFactionGroup('player')
addon.PLAYER_FACTION_ID = Enum.PvPFaction[addon.PLAYER_FACTION]
addon.PLAYER_GUID = UnitGUID('player')

addon.POWER_TYPE_TOKEN = {
	[Enum.PowerType.Mana] = 'MANA',
	[Enum.PowerType.Rage] = 'RAGE',
	[Enum.PowerType.Focus] = 'FOCUS',
	[Enum.PowerType.Energy] = 'ENERGY',
	[Enum.PowerType.ComboPoints] = 'COMBO_POINTS',
	[Enum.PowerType.Runes] = 'RUNES',
	[Enum.PowerType.RunicPower] = 'RUNIC_POWER',
	[Enum.PowerType.SoulShards] = 'SOUL_SHARDS',
	[Enum.PowerType.LunarPower] = 'LUNAR_POWER',
	[Enum.PowerType.HolyPower] = 'HOLY_POWER',
	[Enum.PowerType.Maelstrom] = 'MAELSTROM',
	[Enum.PowerType.Chi] = 'CHI',
	[Enum.PowerType.Insanity] = 'INSANITY',
	[Enum.PowerType.ArcaneCharges] = 'ARCANE_CHARGES',
	[Enum.PowerType.Fury] = 'FURY',
	[Enum.PowerType.Essence] = 'ESSENCE',
}

addon.POWER_TOKEN_TYPE = {}
for powerType, powerToken in next, addon.POWER_TYPE_TOKEN do
	addon.POWER_TOKEN_TYPE[powerToken] = powerType
end

addon.CLASS_SPECIALIZATION_ROLE = {}
for classIndex = 1, GetNumClasses() do
	local _, classToken, classID = GetClassInfo(classIndex)
	if classToken then
		addon.CLASS_SPECIALIZATION_ROLE[classToken] = {}

		for specIndex = 1, 4 do
			local _, _, _, _, role = GetSpecializationInfoForClassID(classID, specIndex)
			if role then
				addon.CLASS_SPECIALIZATION_ROLE[classToken][specIndex] = role
			end
		end
	end
end

addon.CLASS_RESURRECT_SPELLS = {
	DRUID = addon:IsForever() and {1237951, 1237950, 1237949, 1237948, 437138} or 50769, -- Revive
	EVOKER = 361227, -- Return
	MONK = 115178, -- Resuscitate
	PALADIN = {20773, 20772, 10324, 10322, 7328}, -- Redemption
	PRIEST = {20770, 10881, 10880, 2010, 2006}, -- Resurrection
	SHAMAN = {20777, 20776, 20610, 20609, 2008}, -- Ancestral Spirit
}

addon.CLASS_MASS_RESURRECT_SPELLS = {
	DRUID = 212040, -- Revitalize
	EVOKER = 361178, -- Mass Return
	MONK = 212051, -- Reawaken
	PALADIN = 212056, -- Absolution
	PRIEST = 212036, -- Mass Resurrection
	SHAMAN = 212048, -- Ancestral Vision
}

addon.CLASS_RESURRECT_COMBAT_SPELLS = {
	DEATHKNIGHT = 61999, -- Raise Ally
	DRUID = {20748, 20747, 20742, 20739, 20484}, -- Rebirth
	PALADIN = 391054, -- Intercession
	WARLOCK = 20707, -- Soulstone
}

addon.CLASS_BUFF_SPELLS = {
	DRUID = {9885, 9884, 8907, 5234, 6756, 5232, 1126}, -- Mark of the Wild
	EVOKER = 364342, -- Blessing of the Bronze
	MAGE = {10157, 10156, 1461, 1460, 1459}, -- Arcane Intellect
	PRIEST = addon:IsForever() and {10938, 10937, 2791, 1245, 1244, 1243} or 21562, -- Power Word: Fortitude
	-- SHAMAN = {462854, {52127, 192106}}, -- Skyfury + Water/Lightning Shield
	SHAMAN = addon:IsRetail() and 462854, -- Skyfury
	WARRIOR = addon:IsRetail() and 6673, -- Battle Shout
}

addon.CLASS_BUFF_GROUP_SPELLS = { -- forever only
	DRUID = {21850, 21849}, -- Gift of the Wild
	MAGE = 23028, -- Arcane Brilliance
	PRIEST = {21564, 21562}, -- Prayer of Fortitude
}

addon.CLASS_HARMFUL_DISPEL_SPELLS = {
	DRUID = {
		[2782] = { -- Remove Corruption (non-Restoration) @ retail / Remove Curse @ forever
			Curse = true,
			Poison = addon:IsRetail(),
		},
		[2893] = { -- Abolish Poison @ forever
			Poison = addon:IsForever(),
		},
		[8946] = { -- Cure Poison @ forever
			Poison = addon:IsForever(),
		},
		[88423] = { -- Nature's Cure (Restoration only) @ retail
			Magic = true,
			Curse = true,
			Poison = true,
		},
	},
	EVOKER = {
		[360823] = { -- Naturalize (Preservation only)
			Magic = true,
			Poison = true,
		},
		[365585] = { -- Expunge (non-Preservation)
			Poison = true,
		},
		[374251] = { -- Cauterizing Flame (1 min cooldown)
			Bleed = true,
			Poison = true,
			Curse = true,
			Disease = true,
		},
	},
	MAGE = {
		[475] = { -- Remove Curse @ retail / Remove Lesser Curse @ forever
			Curse = true,
		},
	},
	MONK = {
		[115450] = { -- Detox (Mistweaver only)
			Magic = true,
			Poison = 388874, -- with Improved Detox talent
			Disease = 388874, -- with Improved Detox talent
		},
		[218164] = { -- Detox (non-Mistweaver)
			Poison = true,
			Disease = true,
		},
	},
	PALADIN = {
		[1152] = { -- Purify @ forever
			Poison = addon:IsForever(),
			Disease = addon:IsForever(),
		},
		[4987] = { -- Cleanse (Holy only) @ retail / Cleanse @ forever
			Magic = true,
			Poison = addon:IsForever() or (addon:IsRetail() and 393024), -- with Improved Cleanse talent @ retail
			Disease = addon:IsForever() or (addon:IsRetail() and 393024), -- with Improved Cleanse talent @ retail
		},
		[213644] = { -- Cleanse Toxins (non-Holy) @ retail
			Poison = true,
			Disease = true,
		},
	},
	PRIEST = {
		[527] = { -- Purify (Holy and Discipline) @ retail / Dispel Magic @ forever
			Magic = true,
			Disease = addon:IsRetail() and 390632, -- with Improved Purify talent @ retail
		},
		[528] = { -- Cure Disease @ forever
			Disease = addon:IsForever(),
		},
		[552] = { -- Abolish Disease @ forever
			Disease = addon:IsForever(),
		},
		[988] = { -- Dispel Magic (rank 2) @ forever
			Magic = addon:IsForever(),
		},
		[213634] = { -- Purify Disease (Shadow) @ retail
			Disease = true,
		},
	},
	SHAMAN = {
		[526] = { -- Curse Poison @ forever
			Poison = addon:IsForever(),
		},
		[2870] = { -- Cure Disease @ forever
			Disease = addon:IsForever(),
		},
		[8166] = { -- Poison Cleansing Totem @ forever
			Poison = addon:IsForever(),
		},
		[8170] = { -- Disease Cleansing Totem @ forever
			Disease = addon:IsForever(),
		},
		[51886] = { -- Cleanse Spirit (non-Restoration) @ retail
			Curse = true,
		},
		[77130] = { -- Purify Spirit (Restoration only) @ retail
			Magic = true,
			Curse = 383016, -- with Improved Purify Spirit talent
		},
		[383013] = { -- Poison Cleansing Totem @ retail
			Poison = true,
		},
	},
	WARLOCK = {
		[688] = { -- Singe Magic (from Imp pet)
			-- the actual spellID is 89808, but that's a pet spell and we can't count on it,
			-- so we check for the summon spell instead
			Magic = addon:IsRetail(),
		},
		[1276452] = { -- Singe Magic (from Grimoire: Imp Lord)
			-- the actual spellID is 132411, but we can't check for that since it's an override
			-- spell, so we check for the grimoire spell instead
			Magic = true,
		},
	},
}

addon.CLASS_HARMFUL_DISPEL_SELF_SPELLS = {
	HUNTER = {
		[459517] = { -- Emergency Salve
			Poison = true,
			Disease = true,
		},
		-- [212640] = { -- Mending Bandage
		-- 	Bleed = true,
		-- 	Poison = true,
		-- 	Disease = true,
		-- },
	},
	ROGUE = {
		[31224] = { -- Cloak of Shadows
			Magic = true,
			Poison = true,
			Curse = true,
			Disease = true,
		},
	},
}

addon.RACE_HARMFUL_DISPEL_SPELLS = {
	[2] = { -- Orc
		[1299026] = { -- Shatter Curse
			Curse = true,
		},
	},
	[3] = { -- Dwarf
		[20594] = { -- Stoneform
			Magic = addon:IsRetail(),
			Bleed = true,
			Poison = true,
			Curse = addon:IsRetail(),
			Disease = true,
		},
	},
	[34] = { -- Dark Iron Dwarf
		[265221] = { -- Fireblood
			Magic = true,
			Bleed = true,
			Poison = true,
			Curse = true,
			Disease = true,
		}
	},
}

addon.CLASS_HELPFUL_DISPEL_SPELLS = {
	DEMONHUNTER = {
		[278326] = { -- Consume Magic
			Magic = true,
		},
	},
	DRUID = {
		[2908] = { -- Soothe
			Enrage = addon:IsRetail(),
		},
	},
	HUNTER = {
		[19801] = { -- Tranquilizing Shot
			Enrage = true,
			Magic = addon:IsRetail(),
		},
	},
	MAGE = {
		[30449] = { -- Spellsteal
			Magic = true, -- can it only take away magic buffs that are considered stealable, or all magic buffs?
		},
	},
	MONK = {
		[115078] = { -- Paralysis
			Enrage = 450432, -- with Pressure Points talent
		},
	},
	PRIEST = {
		[528] = { -- Dispel Magic
			Magic = true,
		},
		[988] = { -- Dispel Magic (rank 2)
			Magic = true,
		},
		[32375] = { -- Mass Dispel
			Magic = true,
		},
	},
	ROGUE = {
		[5938] = { -- Shiv
			Enrage = addon:IsRetail(),
		},
	},
	SHAMAN = {
		[370] = { -- Purge
			Magic = true,
		},
		[8012] = { -- Purge (rank 2)
			Magic = true,
		},
		[378773] = { -- Greater Purge
			Magic = true,
		},
	},
	WARLOCK = {
		[691] = { -- Devour Magic (from Felhunter pet)
			-- the actual spellID is 19505, but that's a pet spell and we can't count on it,
			-- so we check for the summon spell instead
			Magic = addon:IsRetail(),
		},
		[1276467] = { -- Devour Magic (from Grimoire: Fel Ravager)
			-- the actual spellID is 388215, but we can't check for that since it's an override
			-- spell, so we check for the grimoire spell instead
			Magic = true,
		},
	},
}

addon.RACE_HELPFUL_DISPEL_SPELLS = {
	[10] = { -- Blood Elf
		[25046] = { -- Arcane Torrent (Rogue)
			Magic = true,
		},
		[28730] = { -- Arcane Torrent (Mage/Warlock)
			Magic = true,
		},
		[50613] = { -- Arcane Torrent (Death Knight)
			Magic = true,
		},
		[69179] = { -- Arcane Torrent (Warrior)
			Magic = true,
		},
		[80483] = { -- Arcane Torrent (Hunter)
			Magic = true,
		},
		[129597] = { -- Arcane Torrent (Monk)
			Magic = true,
		},
		[155145] = { -- Arcane Torrent (Paladin)
			Magic = true,
		},
		[202719] = { -- Arcane Torrent (Demon Hunter)
			Magic = true,
		},
		[232633] = { -- Arcane Torrent (Priest)
			Magic = true,
		},
	},
}
