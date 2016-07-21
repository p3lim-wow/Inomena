local E, F = unpack(select(2, ...))

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

local function MerchantUpdate(_, state)
	if(not state) then
		state = GetMerchantFilter()
	end

	for _, Button in next, merchant do
		Button:SetChecked(Button.category == state)
	end
end

local function MerchantClick(self)
	MerchantFrame_SetFilter(MerchantFrame, self.category)
	MerchantUpdate(nil, self.category)
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:AddLine(self.tooltip)
	GameTooltip:Show()
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

function E:MERCHANT_SHOW()
	for index = 1, GetNumSpecializations() do
		local _, name, _, texture = GetSpecializationInfo(index)
		merchant[index + 3] = {_G['LE_LOOT_FILTER_SPEC' .. index], texture, name}
	end

	for index = 1, #merchant do
		local info = merchant[index]
		local Button = CreateButton(MerchantFrame, MerchantClick, info[2])
		Button.category = info[1]
		Button.tooltip = info[3]

		merchant[index] = Button

		if(index == 1) then
			Button:SetPoint('TOPRIGHT', -10, -32)
		else
			Button:SetPoint('RIGHT', merchant[index - 1], 'LEFT', -6, 0)
		end
	end

	merchant[3]:GetRegions():SetTexCoord(unpack(CLASS_ICON_TCOORDS[select(2, UnitClass('player'))]))

	MerchantFrameLootFilter:Hide()

	E:RegisterEvent('MERCHANT_SHOW', MerchantUpdate)

	return true
end