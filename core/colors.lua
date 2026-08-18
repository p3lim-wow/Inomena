local _, addon = ...

-- shared colors used everywhere

addon.colors = {}

addon.colors.white = addon:CreateColor(1, 1, 1)
addon.colors.grey = addon:CreateColor(127, 127, 127)
addon.colors.red = addon:CreateColor(240, 25, 25)
addon.colors.blue = addon:CreateColor(0, 144, 255)
addon.colors.yellow = addon:CreateColor(253, 219, 0)
addon.colors.magenta = addon:CreateColor(230, 95, 232)

-- inject colors from existing sources

addon.colors.class = {}
for index = 1, GetNumClasses() do
	local _, classToken = GetClassInfo(index)
	if classToken then -- can actually be nil
		addon.colors.class[classToken] = C_ClassColor.GetClassColor(classToken)
	end
end

addon.colors.reaction = {}
for key, color in next, FACTION_BAR_COLORS do
	addon.colors.reaction[key] = addon:CreateColor(color.r, color.g, color.b)
end

addon.colors.power = {}
for powerToken, color in next, PowerBarColor do
	local powerType = addon.POWER_TOKEN_TYPE[powerToken]
	if powerType then
		addon.colors.power[powerType] = addon:CreateColor(color.r, color.g, color.b)

		-- add atlases too
		if color.atlas then
			addon.colors.power[powerType].atlas = color.atlas
		end
	end
end

-- replace some of the colors I don't agree with
addon.colors.power[Enum.PowerType.Mana] = addon.colors.blue
addon.colors.power[Enum.PowerType.ArcaneCharges] = addon:CreateColor(186, 77, 188)
addon.colors.power[Enum.PowerType.SoulShards] = addon:CreateColor(135, 136, 238)

-- add missing power colors
addon.colors.power[Enum.PowerType.Essence] = addon:CreateColor(100, 173, 206)
addon.colors.power[Enum.PowerType.RuneBlood] = addon:CreateColor(247, 65, 57)
addon.colors.power[Enum.PowerType.RuneFrost] = addon:CreateColor(148, 203, 247)
addon.colors.power[Enum.PowerType.RuneUnholy] = addon:CreateColor(173, 235, 66)

addon.colors.faction = {}
addon.colors.faction.Alliance = addon:CreateColor(PLAYER_FACTION_COLOR_ALLIANCE:GetRGB())
addon.colors.faction.Horde = addon:CreateColor(PLAYER_FACTION_COLOR_HORDE:GetRGB())
addon.colors.faction.Neutral = addon.colors.white

-- custom colors

addon.colors.healing = addon:CreateColor(140, 255, 46, 0.5)
addon.colors.absorb = addon:CreateColor(67, 235, 231)

addon.colors.nameplate = addon:CreateColor(131, 130, 203)
addon.colors.focus = addon:CreateColor(56, 188, 255)
addon.colors.highlight = addon:CreateColor(1, 1, 1, 0.5)

addon.colors.threat = {
	high = addon:CreateColor(227, 68, 68),
	low = addon:CreateColor(227, 147, 68),
}

addon.colors.power.DevourerMeta = addon:CreateColor(97, 137, 210)
addon.colors.power.DevourerStar = addon:CreateColor(175, 112, 230)

addon.colors.durability = {
	-- alternative to INVENTORY_ALERT_COLORS
	[0] = addon:CreateColor(100, 198, 53),
	[1] = addon:CreateColor(255, 209, 46),
	[2] = addon:CreateColor(237, 18, 18),
}

addon.colors.skyriding = {
	normal = addon:CreateColor(77, 164, 194),
	thrill = addon:CreateColor(168, 135, 65),
}

addon.colors.creature = {
	boss = addon:CreateColor(255, 84, 54),
	lieutenant = addon:CreateColor(223, 120, 255),
	caster = addon:CreateColor(91, 192, 255),
	melee = addon:CreateColor(204, 181, 144),
	trivial = addon:CreateColor(211, 211, 211),
}

addon.colors.cast = {
	importantshielded = addon.colors.magenta,
	shielded = addon.colors.grey,
	important = addon:CreateColor(252, 89, 0),
	normal = addon.colors.yellow,
	interrupted = addon:CreateColor(76, 76, 76),
	global = addon.colors.blue,
}

addon.colors.chat = { -- only the ones we override
	OFFICER = addon:CreateColor(191, 127, 127),
	RAID = addon:CreateColor(0, 255, 204),
	RAID_LEADER = addon:CreateColor(0, 255, 204),
	RAID_WARNING = addon:CreateColor(255, 64, 64),
	BATTLEGROUND_LEADER = addon:CreateColor(255, 127, 0),
	PARTY_LEADER = addon:CreateColor(170, 170, 255),
	BN_WHISPER = addon:CreateColor(255, 127, 255),
	BN_WHISPER_INFORM = addon:CreateColor(255, 127, 255),
	INSTANCE_CHAT_LEADER = addon:CreateColor(255, 127, 0),
}

addon.colors.chatTab = {
	alert = addon.colors.red,
	hover = addon.colors.blue,
	active = addon.colors.white,
	inactive = addon.colors.grey,
}

addon.colors.tooltip = {
	greyed = addon.colors.grey,
}
