local _, addon = ...

local function CreateColor(r, g, b)
	-- handy conversion of 255 color space
	if r > 1 or g > 1 or b > 1 then
		return _G.CreateColor(r / 255, g / 255, b / 255)
	end
	return _G.CreateColor(r, g, b)
end

addon.colors = {}
addon.colors.power = {}
for powerTypeName, color in next, _G.PowerBarColor do
	local powerType = addon.POWER_NAME_TYPE[powerTypeName]
	if powerType then
		addon.colors.power[powerType] = CreateColor(color.r, color.g, color.b)

		-- add the atlases too
		if color.atlas then
			addon.colors.power[powerType].atlas = color.atlas
		end
	end
end

-- replace some default colors I don't agree with
addon.colors.power[Enum.PowerType.Mana] = CreateColor(0, 144, 255)
addon.colors.power[Enum.PowerType.ArcaneCharges] = CreateColor(186, 77, 188)
addon.colors.power[Enum.PowerType.SoulShards] = CreateColor(135, 136, 238) -- TODO: maybe use green color if learned green fire

-- add missing power colors, typically because blizzard uses textures instead
addon.colors.power[Enum.PowerType.Essence] = CreateColor(1, 1, 1) -- TODO
addon.colors.power[Enum.PowerType.RuneBlood] = CreateColor(247, 65, 57)
addon.colors.power[Enum.PowerType.RuneFrost] = CreateColor(148, 203, 247) -- TODO: too light
addon.colors.power[Enum.PowerType.RuneUnholy] = CreateColor(173, 235, 66)

addon.colors.school = {
	Curse = CreateColor(0.8, 0, 1),
	Disease = CreateColor(0.8, 0.6, 0),
	Magic = CreateColor(0, 0.8, 1),
	Poison = CreateColor(0, 0.8, 0),
}

addon.colors.class = {}
for className in next, _G.RAID_CLASS_COLORS do
	addon.colors.class[className] = C_ClassColor.GetClassColor(className)
end
