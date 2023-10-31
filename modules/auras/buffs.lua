local _, addon = ...

local MAX_DISPLAY_DURATION = 90 -- seconds

local auraMixin = {}
function auraMixin:UpdateTooltip()
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')

	if self:GetAttribute('index') then
		GameTooltip:SetUnitAura(self:GetParent():GetAttribute('unit'), self:GetID(), 'HELPFUL')
	elseif self:GetAttribute('target-slot') then
		-- GameTooltip:SetInventoryItem('player', self:GetID())
		GameTooltip:SetSpellByID(self.enchantSpellID)
		GameTooltip:AddLine(addon:FormatAuraTime(self.expiration), 1, 1, 1)
		GameTooltip:Show() -- re-render
	end
end

function auraMixin:UpdateDuration(elapsed)
	if self.expiration then
		self.expiration = math.max(self.expiration - elapsed, 0)

		if self.expiration > 0 and self.expiration <= MAX_DISPLAY_DURATION then
			self.Duration:SetFormattedText('%d', self.expiration)
		else
			self.Duration:SetText()
		end
	end
end

function auraMixin:UpdateAura(index)
	local unit = self:GetParent():GetAttribute('unit')
	local exists, texture, count, _, _, expiration = UnitAura(unit, index, 'HELPFUL')
	if exists then
		self.Icon:SetTexture(texture)
		self.Count:SetText(count > 1 and count or '')
		self.expiration = expiration - GetTime()
	end
end

function auraMixin:UpdateEnchant(inventorySlotIndex)
	local duration, count, enchantID, _
	if inventorySlotIndex == 16 then -- main hand
		_, duration, count, enchantID = GetWeaponEnchantInfo()
	elseif inventorySlotIndex == 17 then -- offhand
		_, _, _, _, _, duration, count, enchantID = GetWeaponEnchantInfo()
	end

	self.enchantSpellID = addon.ENCHANT_IDS[enchantID]
	-- self.Icon:SetTexture(GetInventoryItemTexture('player', inventorySlotIndex))
	self.Icon:SetTexture(GetSpellTexture(self.enchantSpellID))
	self.Count:SetText(count and count > 1 or '')
	self.expiration = duration / 1000
	self:SetBorderColor(0.6, 0, 1) -- some flare
end

function auraMixin:OnAttributeChanged(attribute, value)
	if attribute == 'index' then
		self:UpdateAura(value)
	elseif attribute == 'target-slot' then
		self:UpdateEnchant(value)
	end
end

local function handleChild(self)
	Mixin(self, addon.widgetMixin, auraMixin)
	addon:AddBackdrop(self)

	self:SetScript('OnEnter', self.UpdateTooltip)
	self:SetScript('OnLeave', GameTooltip_Hide)
	self:SetScript('OnUpdate', self.UpdateDuration)

	self:RegisterForClicks('RightButtonDown')
	self:HookScript('OnAttributeChanged', self.OnAttributeChanged)

	local Icon = self:CreateIcon()
	Icon:SetAllPoints()
	self.Icon = Icon

	local Count = self:CreateText()
	Count:SetPoint('CENTER', self, 'BOTTOM')
	Count:SetJustifyH('CENTER')
	self.Count = Count

	local Duration = self:CreateText(13)
	Duration:SetPoint('TOPLEFT', 1, -1)
	Duration:SetJustifyH('LEFT')
	self.Duration = Duration
end


local Buffs = CreateFrame('Frame', nil, WorldFrame, 'SecureAuraHeaderTemplate')
Buffs:SetPoint('TOPRIGHT', Minimap, 'TOPLEFT', -20, 0)

-- make sure the auras are hidden when UI is hidden since we parent to WorldFrame
UIParent:HookScript('OnShow', function()
	Buffs:SetAlpha(1)
end)
UIParent:HookScript('OnHide', function()
	Buffs:SetAlpha(0)
end)

-- set up for player buffs
Buffs:SetAttribute('template', 'SecureActionButtonTemplate')
Buffs:SetAttribute('unit', 'player')
Buffs:SetAttribute('filter', 'helpful')
Buffs:SetAttribute('includeWeapons', 1)
Buffs:SetAttribute('weaponTemplate', Buffs:GetAttribute('template'))

-- sorting
Buffs:SetAttribute('sortMethod', 'TIME')
Buffs:SetAttribute('sortDirection', '-') -- shortest to longest, left to right

-- position and size for children
Buffs:SetAttribute('point', 'TOPRIGHT')
Buffs:SetAttribute('minWidth', 510)
Buffs:SetAttribute('minHeight', 210)
Buffs:SetAttribute('xOffset', -43)
Buffs:SetAttribute('wrapYOffset', -43)
Buffs:SetAttribute('wrapAfter', 12)
Buffs:SetAttribute('initialConfigFunction', [[
	self:SetAttribute('type2', 'cancelaura')
	self:SetWidth(36)
	self:SetHeight(36)
]])

-- show vehicle buffs
RegisterAttributeDriver(Buffs, 'unit', '[vehicleui] vehicle; player')

-- hook into attribute changes so we can tweak each child
Buffs:HookScript('OnAttributeChanged', function(self, attribute, child)
	if attribute:match('^child%d+$') or attribute:match('^tempenchant%d$') then
		handleChild(child)
	end
end)

Buffs:Show() -- the template is hidden by default

-- make sure borders render right, everything is scaled based on WorldFrame
addon:SetPixelScale(Buffs)
