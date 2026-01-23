local _, addon = ...

addon.SPACING = 5

addon.PLAYER_CLASS = UnitClassBase('player')
addon.PLAYER_FACTION = UnitFactionGroup('player')
addon.PLAYER_FACTION_ID = Enum.PvPFaction[addon.PLAYER_FACTION]
addon.PLAYER_REALM = GetRealmName()
