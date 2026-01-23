local _, addon = ...
local oUF = addon.oUF

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

-- "disable" the "None" debuff color in oUF by coloring it the same as the default border color,
-- don't want to mistake no type for bleeds
oUF.colors.dispel[oUF.Enum.DispelType.None] = oUF:CreateColor(0, 0, 0)
