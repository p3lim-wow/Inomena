local _, addon = ...

addon.SPACING = 5

addon.PLAYER_CLASS = UnitClassBase('player')
addon.PLAYER_FACTION = UnitFactionGroup('player')
addon.PLAYER_FACTION_ID = Enum.PvPFaction[addon.PLAYER_FACTION]
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

addon.CLASS_DISPEL_SPELLS = {
	DRUID = {
		88423, -- Nature's Cure
		2782, -- Remove Corruption
	},
	EVOKER = {
		360823, -- Naturalize
	},
	MAGE = {
		475, -- Remove Curse
	},
	MONK = {
		115450, -- Detox (mistweaver)
		218164, -- Detox
	},
	PALADIN = {
		4987, -- Cleanse
		213644, -- Cleanse Toxins
	},
	PRIEST = {
		527, -- Purify
		213634, -- Purify Disease
	},
	SHAMAN = {
		77130, -- Purify Spirit
		51886, -- Cleanse Spirit
	},
}
