local _, Inomena = ...

local guild = {
	{'reputation', [=[Interface\Icons\Achievement_GuildPerk_HonorableMention]=], GUILD_REPUTATION},
	{'tradeskill', [=[Interface\Icons\Achievement_GuildPerk_WorkingOvertime]=], TRADE_SKILLS},
	{'achievement', [=[Interface\Icons\Ability_Warrior_InnerRage]=], ACHIEVEMENT_POINTS},
	{'totalxp', [=[Interface\Icons\Achievement_GuildPerk_MrPopularity_Rank2]=], GUILD_XP_TOTAL},
	{'weeklyxp', [=[Interface\Icons\Achievement_GuildPerk_MrPopularity]=], GUILD_XP_WEEKLY},
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

	for _, button in pairs(guild) do
		button:SetChecked(button == self)
	end
end

local function CreateButton(parent, click, texture)
	local button = CreateFrame('CheckButton', nil, parent)
	button:SetSize(26, 26)
	button:SetScript('OnEnter', OnEnter)
	button:SetScript('OnLeave', GameTooltip_Hide)
	button:SetScript('OnClick', click)

	local icon = button:CreateTexture(nil, 'BACKGROUND')
	icon:SetAllPoints()
	icon:SetTexture(texture)
	icon:SetTexCoord(4/64, 60/64, 4/64, 60/64)

	local normal = button:CreateTexture()
	normal:SetTexture([=[Interface\Buttons\UI-Quickslot2]=])
	normal:SetSize(46, 46)
	normal:SetPoint('CENTER')

	button:SetNormalTexture(normal)
	button:SetPushedTexture([=[Interface\Buttons\UI-Quickslot-Depress]=])
	button:SetHighlightTexture([=[Interface\Buttons\ButtonHilight-Square]=])
	button:SetCheckedTexture([=[Interface\Buttons\CheckButtonHilight]=])

	return button
end

Inomena.RegisterEvent('ADDON_LOADED', function(addon)
	if(addon == 'Blizzard_GuildUI') then
		local offline = GuildRosterShowOfflineButton
		offline:SetSize(26, 26)
		offline:ClearAllPoints()
		offline:SetPoint('TOPRIGHT', -24, -36)
		offline.tooltip = SHOW_OFFLINE_MEMBERS
		offline:SetScript('OnEnter', OnEnter)
		offline:SetScript('OnLeave', GameTooltip_Hide)
		offline:GetRegions():SetText()

		for index, info in pairs(guild) do
			local button = CreateButton(GuildRosterFrame, GuildClick, info[2])
			button:SetChecked(GetCVar('guildRosterView') == info[1])
			button.category = info[1]
			button.tooltip = info[3]

			guild[index] = button

			if(index == 1) then
				button:SetPoint('RIGHT', offline, 'LEFT')
			else
				button:SetPoint('RIGHT', guild[index - 1], 'LEFT', -6, 0)
			end
			
		end

		GuildRosterViewDropdown:Hide()
	end
end)

local factionTexture
if(UnitFactionGroup('player') == 'Alliance') then
	factionTexture = [=[Interface\Icons\Achievement_PvP_A_A]=]
elseif(UnitFactionGroup('player') == 'Horde') then
	factionTexture = [=[Interface\Icons\Achievement_PvP_A_H]=]
else
	factionTexture = [=[Interface\Icons\achievement_guild_classypanda]=]
end

local merchant = {
	{LE_LOOT_FILTER_ALL, factionTexture, ALL},
	{LE_LOOT_FILTER_BOE, [=[Interface\Icons\Inv_Misc_Coin_02]=], ITEM_BIND_ON_EQUIP},
	{LE_LOOT_FILTER_CLASS, [=[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]=], UnitClass('player')},
}

local function MerchantUpdate(state)
	for _, button in pairs(merchant) do
		button:SetChecked(button.category == state)
	end
end

local function MerchantClick(self)
	MerchantFrame_SetFilter(MerchantFrame, self.category)
	MerchantUpdate(self.category)
end

local initialized
Inomena.RegisterEvent('MERCHANT_SHOW', function()
	if(not initialized) then
		for index = 1, GetNumSpecializations() do
			local _, name, _, texture = GetSpecializationInfo(index)
			merchant[index + 3] = {_G['LE_LOOT_FILTER_SPEC' .. index], texture, name}
		end

		for index = 1, #merchant do
			local info = merchant[index]
			local button = CreateButton(MerchantFrame, MerchantClick, info[2])
			button.category = info[1]
			button.tooltip = info[3]

			merchant[index] = button

			if(index == 1) then
				button:SetPoint('TOPRIGHT', -10, -32)
			else
				button:SetPoint('RIGHT', merchant[index - 1], 'LEFT', -6, 0)
			end
		end

		merchant[3]:GetRegions():SetTexCoord(unpack(CLASS_ICON_TCOORDS[select(2, UnitClass('player'))]))

		MerchantFrameLootFilter:Hide()

		initialized = true
	end

	MerchantUpdate(GetMerchantFilter())
end)
