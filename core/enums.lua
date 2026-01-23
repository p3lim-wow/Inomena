local _, addon = ...

-- I wish blizzard would add these

addon.enums = {}

addon.enums.ClassSpecializations = {
	-- useful with C_SpecializationInfo.GetSpecialization()
	DEATHKNIGHT = {
		Blood = 1,
		Frost = 2,
		Unholy = 3,
	},
	DEMONHUNTER = {
		Havoc = 1,
		Vengeance = 2,
		Devourer = 3,
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
		Augmentation = 3,
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

addon.enums.DruidForms = {
	-- useful with GetShapeshiftFormID()
	Cat = 1,
	TreeOfLife = 2,
	Travel = 3,
	Aquatic = 4,
	Bear = 5,
	SwiftFlight = 27,
	Flight = 29,
	Moonkin = 31,
}
