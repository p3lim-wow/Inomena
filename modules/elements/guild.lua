local E, F, C = unpack(select(2, ...))

local guild = {
	{'reputation', [[Interface\Icons\Achievement_GuildPerk_HonorableMention]], GUILD_REPUTATION},
	{'tradeskill', [[Interface\Icons\Achievement_GuildPerk_WorkingOvertime]], TRADE_SKILLS},
	{'achievement', [[Interface\Icons\Ability_Warrior_InnerRage]], ACHIEVEMENT_POINTS},
	{'guildStatus', [[Interface\Icons\Achievement_GuildPerk_Everyones a Hero_Rank2]], GUILD_STATUS},
	{'playerStatus', [[Interface\Icons\Warrior_Talent_Icon_Blitz]], PLAYER_STATUS},
}

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:AddLine(self.tooltip)
	GameTooltip:Show()
end

local function OnClick(self)
	SetCVar('guildRosterView', self.category)
	GuildRoster_SetView(self.category)
	GuildRoster()
	GuildRoster_Update()

	for _, Button in next, guild do
		Button:SetChecked(Button == self)
	end
end

function E:ADDON_LOADED(addon)
	if(addon == 'Blizzard_GuildUI') then
		local Offline = GuildRosterShowOfflineButton
		Offline:SetSize(26, 26)
		Offline:ClearAllPoints()
		Offline:SetPoint('TOPRIGHT', -24, -36)
		Offline:SetScript('OnEnter', OnEnter)
		Offline:SetScript('OnLeave', GameTooltip_Hide)
		Offline:GetRegions():SetText()
		Offline.tooltip = SHOW_OFFLINE_MEMBERS

		for index, info in next, guild do
			local Button = CreateFrame('CheckButton', C.Name .. 'GuildButton' .. index, GuildRosterFrame)
			Button:SetSize(26, 26)
			Button:SetScript('OnClick', OnClick)
			Button:SetScript('OnEnter', OnEnter)
			Button:SetScript('OnLeave', GameTooltip_Hide)
			Button:SetChecked(GetCVar('guildRosterView') == info[1])

			local Icon = Button:CreateTexture('$parentIcon', 'BACKGROUND')
			Icon:SetAllPoints()
			Icon:SetTexture(info[2])
			Icon:SetTexCoord(4/64, 60/64, 4/64, 60/64)

			local Normal = Button:CreateTexture('$parentNormalTexture')
			Normal:SetTexture([[Interface\Buttons\UI-Quickslot2]])
			Normal:SetSize(46, 46)
			Normal:SetPoint('CENTER')

			Button:SetNormalTexture(Normal)
			Button:SetPushedTexture([[Interface\Buttons\UI-Quickslot-Depress]])
			Button:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]])
			Button:SetCheckedTexture([[Interface\Buttons\CheckButtonHilight]])

			Button.category = info[1]
			Button.tooltip = info[3]

			if(index == 1) then
				Button:SetPoint('RIGHT', Offline, 'LEFT')
			else
				Button:SetPoint('RIGHT', guild[index - 1], 'LEFT', -6, 0)
			end

			guild[index] = Button
		end

		GuildRosterViewDropdown:Hide()
	end
end
