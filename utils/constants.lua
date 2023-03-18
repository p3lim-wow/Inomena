local _, addon = ...

addon.PLAYER_CLASS = UnitClassBase('player')

addon.POWER_TYPE_NAME = {
	[Enum.PowerType.Mana] = 'MANA', -- 0
	[Enum.PowerType.Rage] = 'RAGE', -- 1
	[Enum.PowerType.Focus] = 'FOCUS', -- 2
	[Enum.PowerType.Energy] = 'ENERGY', -- 3
	[Enum.PowerType.ComboPoints] = 'COMBO_POINTS', -- 4
	[Enum.PowerType.Runes] = 'RUNES', -- 5
	[Enum.PowerType.RunicPower] = 'RUNIC_POWER', -- 6
	[Enum.PowerType.SoulShards] = 'SOUL_SHARDS', -- 7
	[Enum.PowerType.LunarPower] = 'LUNAR_POWER', -- 8
	[Enum.PowerType.HolyPower] = 'HOLY_POWER', -- 9
	[Enum.PowerType.Maelstrom] = 'MAELSTROM', -- 11
	[Enum.PowerType.Chi] = 'CHI', -- 12
	[Enum.PowerType.Insanity] = 'INSANITY', -- 13
	[Enum.PowerType.ArcaneCharges] = 'ARCANE_CHARGES', -- 16
	[Enum.PowerType.Fury] = 'FURY', -- 17
	[Enum.PowerType.Essence] = 'ESSENCE', -- 19
}

addon.POWER_NAME_TYPE = {}
for type, name in next, addon.POWER_TYPE_NAME do
	addon.POWER_NAME_TYPE[name] = type
end
