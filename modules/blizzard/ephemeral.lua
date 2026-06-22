
-- deal with ephemeral features that usually only stay for a single season

-- hide the landing page button by default
ExpansionLandingPageMinimapButton:SetParent(UIParent)
ExpansionLandingPageMinimapButton:ClearAllPoints()
ExpansionLandingPageMinimapButton:SetPoint('BOTTOMRIGHT', 9999, 9999) -- off-screen somewhere

-- attach it to the character frame if it's an expansion feature (not garrison)
CharacterFrame:HookScript('OnShow', function()
	if ExpansionLandingPageMinimapButton:IsExpansionOverlayMode() and C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(LE_EXPANSION_MIDNIGHT) then
		ExpansionLandingPageMinimapButton:SetParent(PaperDollSidebarTabs)
		ExpansionLandingPageMinimapButton:SetFrameStrata('HIGH')
		ExpansionLandingPageMinimapButton:ClearAllPoints()
		ExpansionLandingPageMinimapButton:SetPoint('CENTER', CharacterFrame, 'TOPRIGHT', 0, -120)
	else
		-- hide it again
		ExpansionLandingPageMinimapButton:SetParent(UIParent)
		ExpansionLandingPageMinimapButton:ClearAllPoints()
		ExpansionLandingPageMinimapButton:SetPoint('BOTTOMRIGHT', 9999, 9999)
	end
end)
