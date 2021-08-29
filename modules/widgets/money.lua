local _, addon = ...

function addon:PLAYER_LOGIN()
	if not InomenaMoney then
		InomenaMoney = {}
	end

	local realm = GetRealmID()
	if not InomenaMoney[realm] then
		InomenaMoney[realm] = {}
	end

	local character = UnitName('player') .. ':' .. (UnitClassBase('player'))
	if not InomenaMoney[realm][character] then
		InomenaMoney[realm][character] = GetMoney()
	end
end

function addon:PLAYER_MONEY()
	local character = UnitName('player') .. ':' .. (UnitClassBase('player'))
	InomenaMoney[GetRealmID()][character] = GetMoney()
end

local tooltip = addon:CreateButton('Money', ContainerFrame1MoneyFrame)
tooltip:SetAllPoints()
tooltip:SetFrameStrata('HIGH')
tooltip:SetScript('OnLeave', GameTooltip_Hide)
tooltip:SetScript('OnEnter', function(self)
	GameTooltip:SetOwner(self, 'ANCHOR_NONE')
	GameTooltip:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT')

	local total = 0
	for character, money in next, InomenaMoney[GetRealmID()] do
		local name, class = string.split(':', character)

		local color = RAID_CLASS_COLORS[class]
		GameTooltip:AddDoubleLine(color:WrapTextInColorCode(name), addon:FormatShortMoney(money))

		total = total + money
	end

	GameTooltip:AddLine(' ')
	GameTooltip:AddDoubleLine('Total', addon:FormatShortMoney(total))

	GameTooltip:Show()
end)
