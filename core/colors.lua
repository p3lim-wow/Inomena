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

-- custom colors

addon.colors.durability = {
	-- alternative to INVENTORY_ALERT_COLORS
	CreateColor(1, 0.82, 0.18),
	CreateColor(0.93, 0.07, 0.07),
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
	importantinterruptible = addon:CreateColor(128, 206, 64),
	important = addon:CreateColor(221, 51, 51),
	interruptible = addon:CreateColor(95, 175, 139),
	normal = addon:CreateColor(79, 128, 192),
}
