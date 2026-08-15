local _, addon = ...
local oUF = addon.oUF

-- inject our power colors into oUF
for powerType, color in next, addon.colors.power do
	if oUF.colors.power[powerType] then
		local replacement = oUF:CreateColor(color:GetRGB())
		oUF.colors.power[powerType] = replacement

		if addon.POWER_TYPE_TOKEN[powerType] then
			oUF.colors.power[addon.POWER_TYPE_TOKEN[powerType]] = replacement
		end
	end
end

-- darken class colors because the status bar texture we use makes it too bright,
-- we'll instead use addon.colors.class or direct from APIs for fontstrings
for _, color in next, oUF.colors.class do
	local h, s, v = C_ColorUtil.ConvertRGBToHSV(color:GetRGB())
	color:SetRGB(C_ColorUtil.ConvertHSVToRGB(h, s, v * 0.6))
end

-- also darken reaction colors, using addon.colors.reaction instead for fontstrings
for _, color in next, oUF.colors.reaction do
	local h, s, v = C_ColorUtil.ConvertRGBToHSV(color:GetRGB())
	color:SetRGB(C_ColorUtil.ConvertHSVToRGB(h, s, v * 0.6))
end

-- custom health curve colors based on reaction colors, the defaults are just too bright
oUF.colors.health:SetCurve({
	[0] = oUF.colors.reaction[1],
	[0.5] = oUF.colors.reaction[4],
	[1] = oUF.colors.reaction[5],
})

-- oUF doesn't use the rune power type for colors, so we have to map it when replacing
oUF.colors.runes[addon.enums.ClassSpecializations.DEATHKNIGHT.Blood] = oUF:CreateColor(addon.colors.power[Enum.PowerType.RuneBlood]:GetRGB())
oUF.colors.runes[addon.enums.ClassSpecializations.DEATHKNIGHT.Frost] = oUF:CreateColor(addon.colors.power[Enum.PowerType.RuneFrost]:GetRGB())
oUF.colors.runes[addon.enums.ClassSpecializations.DEATHKNIGHT.Unholy] = oUF:CreateColor(addon.colors.power[Enum.PowerType.RuneUnholy]:GetRGB())

-- devourer demon hunter power colors
oUF.colors.power.SOUL_FRAGMENTS[1] = oUF:CreateColor(addon.colors.power.DevourerMeta:GetRGB())
oUF.colors.power.SOUL_FRAGMENTS[2] = oUF:CreateColor(addon.colors.power.DevourerStar:GetRGB())

-- set the "None" debuff type to our default border color, otherwise it can be mistaken for bleeds
oUF.colors.dispel.None = oUF:CreateColor(0, 0, 0)
