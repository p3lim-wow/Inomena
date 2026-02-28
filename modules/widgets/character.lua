local _, addon = ...

-- add faction and race info to character frame

local Text = PaperDollFrame:CreateFontString(nil, nil, 'GameFontNormalSmall2')
Text:SetPoint('TOP', CharacterLevelText, 'BOTTOM', 0, 5)

local function updateText()
	local faction = UnitFactionGroup('player') or 'Neutral'
	Text:SetFormattedText('%s %s', addon.colors.faction[faction]:WrapTextInColorCode(faction), UnitRace('player'))
end

addon:RegisterEvent('PLAYER_LOGIN', updateText)
addon:RegisterEvent('NEUTRAL_FACTION_SELECT_RESULT', updateText)

hooksecurefunc('PaperDollFrame_SetLevel', function()
	-- adjust the parent anchor a little
	CharacterLevelText:SetPointsOffset(0, -37)
end)
