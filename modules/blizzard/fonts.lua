local _, addon = ...

-- use our font for various default UI elements

for object, size in next, {
	-- zone splash text
	ZoneTextString = 28,
	SubZoneTextString = 22,
	PVPArenaTextString = 16,

	-- friendly nameplates in instances (font size doesn't seem to matter)
	SystemFont_NamePlate = 16,
	SystemFont_NamePlateFixed = 16,
	SystemFont_NamePlate_Outlined = 16,
	SystemFont_LargeNamePlate = 16,
	SystemFont_LargeNamePlateFixed = 16,

	-- chat edit box
	ChatFrame1EditBox = 13,
	ChatFrame1EditBoxHeader = 13,

	-- tooltips
	GameTooltipHeaderText = 12,
	GameTooltipText = 12,
	GameTooltipTextSmall = 12,
} do
	_G[object]:SetFont(addon.FONT, size, addon.FONTFLAGS)

	-- if _G[object].SetShadowOffset then -- TODO: check if necessary
		_G[object]:SetShadowOffset(0, 0)
	-- end
end
