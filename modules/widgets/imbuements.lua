local _, addon = ...

-- embedded imbuements in character window

local function updateImbuement(self)
	local slot = self:GetAttribute('target-slot')
	local hasEnchant, expirationMs = select(math.max(1, (slot - 16) * 5), GetWeaponEnchantInfo())
	local duration = C_DurationUtil.CreateDuration()
	if hasEnchant then
		duration:SetTimeFromStart(GetTime(), expirationMs / 1000)
	end

	self.binding:SetDuration(duration)
end

local function appendSlotTooltip(self)
	local hasEnchant = select(math.max(1, (self:GetID() - 16) * 5), GetWeaponEnchantInfo())
	if hasEnchant then
		GameTooltip:AddLine(' ')
		GameTooltip:AddLine('|A:NPE_RightClick:18:18|a Remove weapon imbuement')
		GameTooltip:Show()
	end
end

for parent, slot in next, {
	CharacterMainHandSlot = 16,
	CharacterSecondaryHandSlot = 17,
} do
	local Button = addon:CreateFrame('Button', nil, _G[parent], 'SecureAuraButtonTemplate')
	Button:SetAllPoints()
	Button:SetPassThroughButtons('LeftButton')
	Button:SetPropagateMouseMotion(true)
	Button:SetAttribute('target-slot', slot)
	-- Button:RegisterEvent('WEAPON_ENCHANT_CHANGED', updateImbuement)
	Button:RegisterUnitEvent('UNIT_INVENTORY_CHANGED', 'player', updateImbuement)
	Button:RegisterEvent('PLAYER_LOGIN', updateImbuement)

	local Time = Button:CreateText(13)
	Time:SetPoint('BOTTOM', Button, 'TOP', 0, 3)
	Time:SetJustifyH('CENTER')

	local binding = C_DurationUtil.CreateDurationTextBinding()
	binding:SetFontString(Time)
	binding:SetFormatter(addon.formatters.Enchant)
	binding:Enable()
	Button.binding = binding

	hooksecurefunc(Button:GetParent(), 'UpdateTooltip', appendSlotTooltip)
end
