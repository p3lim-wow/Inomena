local _, addon = ...

local HEIGHT = 6

local FORMAT_PERC = '%s / %s (%d%%)'
local FORMAT_LEVEL = string.format('|cffffcc00%s|r %%d', LEVEL)
local FORMAT_RESTED = string.format('|cff0090ff%s|r %%s (%%d%%%%)', TUTORIAL_TITLE26)
local FORMAT_RENOWN = string.format('|cff00c5fd%s|r %%d', (RENOWN_LEVEL_LABEL:gsub(' %%d', '')))

local experience; do -- xp + rested bar
	experience = addon.widgetMixin.CreateBackdropStatusBar(Minimap)
	experience:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', 0, -addon.SPACING)
	experience:SetPoint('TOPRIGHT', Minimap, 'BOTTOMRIGHT', 0, -addon.SPACING)
	experience:SetHeight(HEIGHT)
	experience:SetStatusBarColor(addon.colors.experience:GetRGB())
	experience:SetBackgroundColor(0, 0, 0, 0) -- hide background, we're using the one from rested
	experience:Hide()
	experience:SetScript('OnLeave', addon.HideTooltip)
	experience:SetScript('OnEnter', function(self)
		local tooltip = addon:GetTooltip(self, 'ANCHOR_NONE')
		tooltip:SetPoint('TOPRIGHT', self, 'TOPLEFT', -addon.SPACING, 0)
		tooltip:SetText(COMBAT_XP_GAIN)
		tooltip:AddLine(FORMAT_LEVEL:format(self.level), 1, 1, 1)

		local cur = BreakUpLargeNumbers(self.cur)
		local max = BreakUpLargeNumbers(self.max)
		local perc = math.floor(self.cur / self.max * 100 + 0.5)
		tooltip:AddLine(FORMAT_PERC:format(cur, max, perc), 1, 1, 1)

		if self.exhaustion > 0 then
			local exhaustion = BreakUpLargeNumbers(self.exhaustion)
			local exhaustionPerc = math.floor(self.exhaustion / self.max * 100 + 0.5)
			tooltip:AddLine(FORMAT_RESTED:format(exhaustion, exhaustionPerc), 1, 1, 1)
		end

		tooltip:Show()
	end)

	local rested = experience:CreateBackdropStatusBar()
	rested:SetAllPoints()
	rested:SetStatusBarColor(addon.colors.rested:GetRGB())
	rested:SetFrameLevel(experience:GetFrameLevel() - 1) -- render below experience

	local function update()
		local maxLevel = GetRestrictedAccountData()
		if maxLevel == 0 then
			maxLevel = GetMaxLevelForPlayerExpansion()
		end

		local level = UnitLevel('player')
		if maxLevel == level or IsXPUserDisabled() then
			experience:Hide()
			return
		end

		local cur, max = UnitXP('player'), UnitXPMax('player')
		local exhaustion = GetXPExhaustion() or 0

		experience:SetMinMaxValues(0, max)
		experience:SetValue(cur, Enum.StatusBarInterpolation.ExponentialEaseOut)
		experience:Show()

		-- data for the tooltip
		experience.cur = cur
		experience.max = max
		experience.exhaustion = exhaustion
		experience.level = level

		rested:SetMinMaxValues(0, max)
		rested:SetValue(math.min(cur + exhaustion, max), Enum.StatusBarInterpolation.ExponentialEaseOut)
	end

	addon:RegisterEvent('PLAYER_LOGIN', update)
	addon:RegisterEvent('PLAYER_XP_UPDATE', update)
	addon:RegisterEvent('PLAYER_LEVEL_UP', update)
	addon:RegisterEvent('UPDATE_EXHAUSTION', update)
	addon:RegisterEvent('UPDATE_EXPANSION_LEVEL', update)
	addon:RegisterEvent('ENABLE_XP_GAIN', update)
	addon:RegisterEvent('DISABLE_XP_GAIN', update)
end

do -- reputation bar
	local reputation = addon.widgetMixin.CreateBackdropStatusBar(Minimap)
	reputation:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', 0, -addon.SPACING)
	reputation:SetPoint('TOPRIGHT', Minimap, 'BOTTOMRIGHT', 0, -addon.SPACING)
	reputation:SetHeight(HEIGHT)
	reputation:Hide()
	reputation:SetScript('OnLeave', addon.HideTooltip)
	reputation:SetScript('OnEnter', function(self)
		local tooltip = addon:GetTooltip(self, 'ANCHOR_NONE')
		tooltip:SetPoint('TOPRIGHT', self, 'TOPLEFT', -addon.SPACING, 0)
		tooltip:SetText(self.name)

		local r, g, b = addon.colors.reaction[self.reaction]:GetRGB()
		if self.renown then
			tooltip:AddLine(FORMAT_RENOWN:format(self.renown), 1, 1, 1)
		else
			tooltip:AddLine(GetText('FACTION_STANDING_LABEL' .. self.reaction, UnitSex('player')), r, g, b)
		end

		if self.max > 1 then
			local cur = BreakUpLargeNumbers(self.cur)
			local max = BreakUpLargeNumbers(self.max)
			local perc = math.floor(self.cur / self.max * 100 + 0.5)
			tooltip:AddLine(FORMAT_PERC:format(cur, max, perc), 1, 1, 1)
		end

		if self.warband then
			tooltip:AddLine(' ')
			tooltip:AddLine(REPUTATION_TOOLTIP_ACCOUNT_WIDE_LABEL, addon.colors.warband:GetRGB())
		end

		tooltip:Show()
	end)

	local paragon = reputation:CreateTexture('OVERLAY', 2)
	paragon:SetPoint('CENTER')
	paragon:SetAtlas('ParagonReputation_Bag', true)

	local paragonGlow = reputation:CreateTexture('OVERLAY', 1)
	paragonGlow:SetPoint('CENTER')
	paragonGlow:SetAtlas('ParagonReputation_Glow', true)

	local function update()
		local data = C_Reputation.GetWatchedFactionData()
		if not data then
			reputation:Hide()
			return
		end

		local min = data.currentReactionThreshold
		local max = data.nextReactionThreshold
		local cur = data.currentStanding
		local reaction = data.reaction
		local hasPendingReward, renown, _

		if C_Reputation.IsMajorFaction(data.factionID) then
			if C_MajorFactions.HasMaximumRenown(data.factionID) then
				max, cur = 1, 1
			else
				local info = C_MajorFactions.GetMajorFactionData(data.factionID)
				max = info.renownLevelThreshold
				cur = info.renownReputationEarned
			end

			renown = C_MajorFactions.GetCurrentRenownLevel(data.factionID)

			-- treat these as paragon
			reaction = MAX_REPUTATION_REACTION + 1
		else
			local friendship = C_GossipInfo.GetFriendshipReputation(data.factionID)
			if friendship and friendship.friendshipFactionID > 0 then
				if friendship.nextThreshold then
					max = friendship.nextThreshold - friendship.reactionThreshold
					cur = friendship.standing - friendship.reactionThreshold
				else
					max, cur = 1, 1
				end
			else
				if reaction ~= MAX_REPUTATION_REACTION then
					max = max - min
					cur = cur - min
				else
					max, cur = 1, 1
				end
			end
		end

		if C_Reputation.IsFactionParagonForCurrentPlayer(data.factionID) then
			cur, max, _, hasPendingReward = C_Reputation.GetFactionParagonInfo(data.factionID)
			cur = cur % max
			reaction = MAX_REPUTATION_REACTION + 1
		end

		reputation:SetMinMaxValues(0, max)
		reputation:SetValue(cur, Enum.StatusBarInterpolation.ExponentialEaseOut)
		reputation:SetStatusBarColor(addon.colors.reaction[reaction]:GetRGB())
		reputation:Show()

		-- data for the tooltip
		reputation.cur = cur
		reputation.max = max
		reputation.name = data.name
		reputation.reaction = reaction
		reputation.renown = renown
		reputation.warband = C_Reputation.IsAccountWideReputation(data.factionID)

		paragon:SetShown(not not hasPendingReward)
		paragonGlow:SetShown(not not hasPendingReward)
	end

	addon:RegisterEvent('UPDATE_FACTION', update)
	addon:RegisterEvent('FACTION_STANDING_CHANGED', update)
	addon:RegisterEvent('QUEST_LOG_UPDATE', update) -- needed to update when taking paragon reward

	-- adjust offset based on the shown state of experience
	experience:HookScript('OnShow', function()
		reputation:SetPointsOffset(0, -(HEIGHT + (addon.SPACING * 2)))
	end)
	experience:HookScript('OnHide', function()
		reputation:SetPointsOffset(0, -addon.SPACING)
	end)
end
