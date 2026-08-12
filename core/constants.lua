local _, addon = ...

addon.SPACING = 5

addon.PLAYER_CLASS = UnitClassBase('player')
addon.PLAYER_RACE = select(3, UnitRace('player'))
addon.PLAYER_FACTION = UnitFactionGroup('player')
addon.PLAYER_FACTION_ID = Enum.PvPFaction[addon.PLAYER_FACTION]
addon.PLAYER_GUID = UnitGUID('player')
addon.PLAYER_REALM = GetRealmName()

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
	DRUID = 50769, -- Revive
	EVOKER = 361227, -- Return
	MONK = 115178, -- Resuscitate
	PALADIN = 7328, -- Redemption
	PRIEST = 2006, -- Resurrection
	SHAMAN = 2008, -- Ancestral Spirit
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
	DRUID = 20484, -- Rebirth
	PALADIN = 391054, -- Intercession
	WARLOCK = 20707, -- Soulstone
}

addon.CLASS_BUFF_SPELLS = {
	DRUID = 1126, -- Mark of the Wild
	EVOKER = 364342, -- Blessing of the Bronze
	MAGE = 1459, -- Arcane Intellect
	PRIEST = 21562, -- Power Word: Fortitude
	SHAMAN = 462854, -- Skyfury
	WARRIOR = 6673, -- Battle Shout
}

addon.CLASS_HARMFUL_DISPEL_SPELLS = {
	DRUID = {
		[88423] = { -- Nature's Cure (Restoration only)
			Magic = true,
			Curse = true,
			Poison = true,
		},
		[2782] = { -- Remove Corruption (non-Restoration)
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
		[475] = { -- Remove Curse
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
		[4987] = { -- Cleanse (Holy only)
			Magic = true,
			Poison = 393024, -- with Improved Cleanse talent
			Disease = 393024, -- with Improved Cleanse talent
		},
		[213644] = { -- Cleanse Toxins (non-Holy)
			Poison = true,
			Disease = true,
		},
	},
	PRIEST = {
		[527] = { -- Purify (Holy and Discipline)
			Magic = true,
			Disease = 390632, -- with Improved Purify talent
		},
		[213634] = { -- Purify Disease (Shadow)
			Disease = true,
		},
	},
	SHAMAN = {
		[77130] = { -- Purify Spirit (Restoration only)
			Magic = true,
			Curse = 383016, -- with Improved Purify Spirit talent
		},
		[51886] = { -- Cleanse Spirit (non-Restoration)
			Curse = true,
		},
		[383013] = { -- Poison Cleansing Totem (2 min cooldown)
			Poison = true,
		},
	},
	WARLOCK = {
		[688] = { -- Singe Magic (from Imp pet)
			-- the actual spellID is 89808, but that's a pet spell and we can't count on it,
			-- so we check for the summon spell instead
			Magic = true,
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
	[3] = { -- Dwarf
		[20594] = { -- Stoneform
			Magic = true,
			Bleed = true,
			Poison = true,
			Curse = true,
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
			Enrage = true,
		},
	},
	HUNTER = {
		[19801] = { -- Tranquilizing Shot
			Enrage = true,
			Magic = true,
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
		[32375] = { -- Mass Dispel
			Magic = true,
		},
	},
	ROGUE = {
		[5938] = { -- Shiv
			Enrage = true,
		},
	},
	SHAMAN = {
		[370] = { -- Purge
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
			Magic = true,
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
