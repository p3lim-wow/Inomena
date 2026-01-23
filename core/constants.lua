local _, addon = ...

addon.SPACING = 5

addon.PLAYER_CLASS = UnitClassBase('player')
addon.PLAYER_FACTION = UnitFactionGroup('player')
addon.PLAYER_FACTION_ID = Enum.PvPFaction[addon.PLAYER_FACTION]
addon.PLAYER_REALM = GetRealmName()

addon.CLASS_BUFF_SPELLS = {
	DRUID = 1126, -- Mark of the Wild
	EVOKER = 364342, -- Blessing of the Bronze
	MAGE = 1459, -- Arcane Intellect
	PRIEST = 21562, -- Power Word: Fortitude
	SHAMAN = 462854, -- Skyfury
	WARRIOR = 6673, -- Battle Shout
}
