local E, F = unpack(select(2, ...))

local guild = {
	{'reputation', [=[Interface\Icons\Achievement_GuildPerk_HonorableMention]=], GUILD_REPUTATION},
	{'tradeskill', [=[Interface\Icons\Achievement_GuildPerk_WorkingOvertime]=], TRADE_SKILLS},
	{'achievement', [=[Interface\Icons\Ability_Warrior_InnerRage]=], ACHIEVEMENT_POINTS},
	{'guildStatus', [=[Interface\Icons\Achievement_GuildPerk_Everyones a Hero_Rank2]=], GUILD_STATUS},
	{'playerStatus', [=[Interface\Icons\Warrior_Talent_Icon_Blitz]=], PLAYER_STATUS},
}

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:AddLine(self.tooltip)
	GameTooltip:Show()
end

local function GuildClick(self)
	SetCVar('guildRosterView', self.category)
	GuildRoster_SetView(self.category)
	GuildRoster()
	GuildRoster_Update()

	for _, Button in next, guild do
		Button:SetChecked(Button == self)
	end
end

local function CreateButton(parent, click, texture)
	local Button = CreateFrame('CheckButton', nil, parent)
	Button:SetSize(26, 26)
	Button:SetScript('OnEnter', OnEnter)
	Button:SetScript('OnLeave', GameTooltip_Hide)
	Button:SetScript('OnClick', click)

	local Icon = Button:CreateTexture(nil, 'BACKGROUND')
	Icon:SetAllPoints()
	Icon:SetTexture(texture)
	Icon:SetTexCoord(4/64, 60/64, 4/64, 60/64)

	local Normal = Button:CreateTexture()
	Normal:SetTexture([=[Interface\Buttons\UI-Quickslot2]=])
	Normal:SetSize(46, 46)
	Normal:SetPoint('CENTER')

	Button:SetNormalTexture(Normal)
	Button:SetPushedTexture([=[Interface\Buttons\UI-Quickslot-Depress]=])
	Button:SetHighlightTexture([=[Interface\Buttons\ButtonHilight-Square]=])
	Button:SetCheckedTexture([=[Interface\Buttons\CheckButtonHilight]=])

	return Button
end

function E:ADDON_LOADED(addon)
	if(addon == 'Blizzard_GuildUI') then
		local Offline = GuildRosterShowOfflineButton
		Offline:SetSize(26, 26)
		Offline:ClearAllPoints()
		Offline:SetPoint('TOPRIGHT', -24, -36)
		Offline.tooltip = SHOW_OFFLINE_MEMBERS
		Offline:SetScript('OnEnter', OnEnter)
		Offline:SetScript('OnLeave', GameTooltip_Hide)
		Offline:GetRegions():SetText()

		for index, info in next, guild do
			local Button = CreateButton(GuildRosterFrame, GuildClick, info[2])
			Button:SetChecked(GetCVar('guildRosterView') == info[1])
			Button.category = info[1]
			Button.tooltip = info[3]

			guild[index] = Button

			if(index == 1) then
				Button:SetPoint('RIGHT', Offline, 'LEFT')
			else
				Button:SetPoint('RIGHT', guild[index - 1], 'LEFT', -6, 0)
			end

		end

		GuildRosterViewDropdown:Hide()
	end
end
