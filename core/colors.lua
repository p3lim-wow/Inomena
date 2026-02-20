local _, addon = ...

-- shared colors used everywhere

addon.colors = {}

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
addon.colors.power[Enum.PowerType.Mana] = addon:CreateColor(0, 144, 255)
addon.colors.power[Enum.PowerType.ArcaneCharges] = addon:CreateColor(186, 77, 188)
addon.colors.power[Enum.PowerType.SoulShards] = addon:CreateColor(135, 136, 238)

-- add missing power colors
addon.colors.power[Enum.PowerType.Essence] = addon:CreateColor(100, 173, 206)
addon.colors.power[Enum.PowerType.RuneBlood] = addon:CreateColor(247, 65, 57)
addon.colors.power[Enum.PowerType.RuneFrost] = addon:CreateColor(148, 203, 247)
addon.colors.power[Enum.PowerType.RuneUnholy] = addon:CreateColor(173, 235, 66)

-- custom colors

addon.colors.healing = addon:CreateColor(140, 1, 46, 0.5)
addon.colors.absorb = addon:CreateColor(67, 235, 231)

addon.colors.nameplate = addon:CreateColor(131, 130, 203)
addon.colors.focus = addon:CreateColor(56, 188, 255)
addon.colors.threat = addon:CreateColor(227, 68, 68)
addon.colors.highlight = addon:CreateColor(1, 1, 1, 0.5)

addon.colors.power.DevourerMeta = addon:CreateColor(97, 137, 210)
addon.colors.power.DevourerStar = addon:CreateColor(175, 112, 230)

addon.colors.durability = {
	-- alternative to INVENTORY_ALERT_COLORS
	CreateColor(1, 0.82, 0.18),
	CreateColor(0.93, 0.07, 0.07),
}

addon.colors.skyriding = {
	normal = addon:CreateColor(77, 164, 194),
	thrill = addon:CreateColor(168, 135, 65),
}

addon.colors.creature = {
	boss = addon:CreateColor(188, 28, 0),
	lieutenant = addon:CreateColor(144, 0, 188),
	caster = addon:CreateColor(0, 116, 188),
	melee = addon:CreateColor(178, 142, 85),
	trivial = addon:CreateColor(110, 110, 110),
	tapped = addon:CreateColor(110, 110, 110),
}

addon.colors.cast = {
	importantshielded = addon:CreateColor(230, 95, 232),
	shielded = addon:CreateColor(132, 132, 132),
	important = addon:CreateColor(252, 89, 0),
	normal = addon:CreateColor(253, 219, 0),
}

addon.colors.chatTab = {
	alert = addon:CreateColor(1, 0, 0),
	hover = addon:CreateColor(0, 153, 255),
	active = addon:CreateColor(1, 1, 1),
	inactive = addon:CreateColor(127, 127, 127),
}
