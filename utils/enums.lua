local _, addon = ...

addon.enum = {}
addon.enum.DruidForms = { -- useful for GetShapeshiftFormID()
	Cat = 1,
	TreeOfLife = 2,
	Travel = 3,
	Aquatic = 4,
	Bear = 5,
	SwiftFlight = 27,
	Flight = 29,
	Moonkin = 31,
}

addon.enum.ClassSpecialization = { -- useful for GetSpecialization()
	DEATHKNIGHT = {
		Blood = 1,
		Frost = 2,
		Unholy = 3,
	},
	DEMONHUNTER = {
		Havoc = 1,
		Vengeance = 2,
	},
	DRUID = {
		Balance = 1,
		Feral = 2,
		Guardian = 3,
		Restoration = 4,
	},
	EVOKER = {
		Devastation = 1,
		Preservation = 2,
	},
	HUNTER = {
		BeastMastery = 1,
		Marksmanship = 2,
		Survival = 3,
	},
	MAGE = {
		Arcane = 1,
		Fire = 2,
		Frost = 3,
	},
	MONK = {
		Brewmaster = 1,
		Mistweaver = 2,
		Windwalker = 3,
	},
	PALADIN = {
		Holy = 1,
		Protection = 2,
		Retribution = 3,
	},
	PRIEST = {
		Discipline = 1,
		Holy = 2,
		Shadow = 3,
	},
	ROGUE = {
		Assassination = 1,
		Outlaw = 2,
		Subtlety = 3,
	},
	SHAMAN = {
		Elemental = 1,
		Enhancement = 2,
		Restoration = 3,
	},
	WARLOCK = {
		Affliction = 1,
		Demonology = 2,
		Destruction = 3,
	},
	WARRIOR = {
		Arms = 1,
		Fury = 2,
		Protection = 3,
	},
}
