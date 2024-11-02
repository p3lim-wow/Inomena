local _, addon = ...

addon.colors = {}
addon.colors.power = {}
for powerTypeName, color in next, _G.PowerBarColor do
	local powerType = addon.POWER_NAME_TYPE[powerTypeName]
	if powerType then
		addon.colors.power[powerType] = addon:CreateColor(color.r, color.g, color.b)

		-- add the atlases too
		if color.atlas then
			addon.colors.power[powerType].atlas = color.atlas
		end
	end
end

-- replace some default colors I don't agree with
addon.colors.power[Enum.PowerType.Mana] = addon:CreateColor(0, 144, 255)
addon.colors.power[Enum.PowerType.ArcaneCharges] = addon:CreateColor(186, 77, 188)
addon.colors.power[Enum.PowerType.SoulShards] = addon:CreateColor(135, 136, 238) -- TODO: maybe use green color if learned green fire

-- add missing power colors, typically because blizzard uses textures instead
addon.colors.power[Enum.PowerType.Essence] = addon:CreateColor(1, 1, 1) -- TODO
addon.colors.power[Enum.PowerType.RuneBlood] = addon:CreateColor(247, 65, 57)
addon.colors.power[Enum.PowerType.RuneFrost] = addon:CreateColor(148, 203, 247) -- TODO: too light
addon.colors.power[Enum.PowerType.RuneUnholy] = addon:CreateColor(173, 235, 66)

addon.colors.school = {
	Curse = addon:CreateColor(0.8, 0, 1),
	Disease = addon:CreateColor(0.8, 0.6, 0),
	Magic = addon:CreateColor(0, 0.8, 1),
	Poison = addon:CreateColor(0, 0.8, 0),
}

addon.colors.class = {}
for index = 1, GetNumClasses() do
	local _, classToken = GetClassInfo(index)
	if classToken then -- can be nil apparently
			addon.colors.class[classToken] = C_ClassColor.GetClassColor(classToken)
	end
end
