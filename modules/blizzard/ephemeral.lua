local _, addon = ...

-- deal with ephemeral features that usually only stay for a single expansion or season

do -- omnium folio
	local button, animations
	CharacterFrame:HookScript('OnShow', function()
		if not C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(LE_EXPANSION_MIDNIGHT) then
			return
		end

		if not button then
			button = CreateFrame('Button', nil, PaperDollSidebarTabs)
			button:SetPoint('CENTER', CharacterFrame, 'TOPRIGHT', -5, -120)
			button:SetSize(53, 53)
			button:SetFrameStrata('HIGH')
			button:SetScript('OnClick', GenerateFlatClosure(ToggleExpansionLandingPage))
			button:SetScript('OnLeave', addon.HideTooltip)
			button:SetScript('OnEnter', function(self)
				local tooltip = addon:GetTooltip(self, 'ANCHOR_RIGHT')
				tooltip:SetText(MIDNIGHT_LANDING_PAGE_TITLE, 1, 1, 1)
				tooltip:AddLine(MIDNIGHT_LANDING_PAGE_TOOLTIP, nil, nil, nil, true)
				tooltip:Show()
			end)

			button:SetNormalAtlas('midnight-landingbutton-up')
			button:SetPushedAtlas('midnight-landingbutton-down')
			button:SetHighlightAtlas('midnight-landingbutton-highlight')
			-- button:SetHighlightAtlas('midnight-landingbutton-circlehighlight')
			button:GetHighlightTexture():SetBlendMode('ADD')

			local glow = button:CreateTexture()
			glow:SetPoint('CENTER', 3, 2)
			glow:SetSize(32, 32)
			glow:SetAtlas('midnight-landingbutton-circleglow')
			glow:SetBlendMode('ADD')
			glow:Hide()

			animations = button:CreateAnimationGroup()
			animations:SetLooping('REPEAT')
			animations:SetScript('OnPlay', GenerateFlatClosure(glow.Show, glow))
			animations:SetScript('OnStop', GenerateFlatClosure(glow.Hide, glow))
			animations:SetScript('OnFinished', GenerateFlatClosure(glow.Hide, glow))

			local animation1 = animations:CreateAnimation('Alpha')
			animation1:SetOrder(0)
			animation1:SetTarget(glow)
			animation1:SetDuration(0.5)
			animation1:SetFromAlpha(0)
			animation1:SetToAlpha(1)

			local animation2 = animations:CreateAnimation('Alpha')
			animation2:SetOrder(1)
			animation2:SetTarget(glow)
			animation2:SetDuration(1)
			animation2:SetFromAlpha(1)
			animation2:SetToAlpha(0)
			animation2:SetStartDelay(0.5)

			local animation3 = animations:CreateAnimation('Scale')
			animation3:SetOrder(1)
			animation3:SetTarget(glow)
			animation3:SetDuration(0.75)
			animation3:SetScaleFrom(0.75, 0.75)
			animation3:SetScaleTo(1.1, 1.1)
		end

		animations:Stop()

		local configID = C_Traits.GetConfigIDBySystemID(48)
		if not configID then
			return
		end

		-- copied from CanPurchaseRuneOfPower in Blizzard_MidnightLandingPage.lua
		local treeCurrencies = C_Traits.GetTreeCurrencyInfo(configID, 1186, false)
		if #treeCurrencies <= 0 then
			return
		end

		local unspentCurrency = treeCurrencies[1].quantity
		if unspentCurrency == 0 then
			return
		end

		for _, nodeID in ipairs(C_Traits.GetTreeNodes(1186)) do
			local nodeCosts = C_Traits.GetNodeCost(configID, nodeID)
			local canAffordNode = (#nodeCosts == 0) or (unspentCurrency >= nodeCosts[1].amount)
			if canAffordNode then
				local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
				for _, entryID in ipairs(nodeInfo.entryIDs) do
					if C_Traits.CanPurchaseRank(configID, nodeID, entryID) then
						animations:Play()
						return
					end
				end
			end
		end
	end)
end
