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

-- custom colors

addon.colors.durability = {
	-- alternative to INVENTORY_ALERT_COLORS
	CreateColor(1, 0.82, 0.18),
	CreateColor(0.93, 0.07, 0.07),
}
