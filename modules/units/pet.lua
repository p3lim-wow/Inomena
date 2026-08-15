local _, addon = ...
local oUF = addon.oUF

local styleName = addon.unitPrefix .. 'Pet'
oUF:RegisterStyle(styleName, function(self)
	Mixin(self, addon.widgetMixin)

	self:RegisterForClicks('AnyUp')
	self:SetSize(120, 20)

	local Health = self:CreateBackdropStatusBar()
	Health:SetPoint('TOP')
	Health:SetSize(self:GetWidth(), 10)
	Health.colorReaction = true
	self.Health = Health

	if addon.units.player.Power then
		-- offset when the player has mana (i.e. for warlocks)
		Health:SetPointsOffset(0, -10)
	end

	local Auras = self:CreateAuras({
		layoutLimit = math.huge,
		growthX = 'LEFT',
		growthY = 'DOWN',
		initialAnchor = 'TOPRIGHT',
	})
	Auras:SetPoint('TOPRIGHT', self, 'TOPLEFT', -addon.SPACING, 0)
	Auras.elementSpacing = addon.SPACING
	Auras.lineSpacing = addon.SPACING
	Auras.size = self:GetHeight(1.2)
	Auras.tooltipAnchor = 'ANCHOR_TOPRIGHT'
	Auras.tooltipOffsetX = 1
	Auras.tooltipOffsetY = 3
	Auras.PostCreateButton = addon.unitShared.PostCreateAura
	Auras:AddGroup('HARMFUL|CROWD_CONTROL', {
		size = self:GetHeight() * 3 -- emphasize!
	})
	Auras:AddGroup('HELPFUL|PLAYER', {
		disableCooldownText = true, -- they're too small to see
		candidateFilters = {
			includeSpellIDs = {
				[136] = true, -- Mend Pet
			}
		}
	})

	local Status = self:CreateText()
	Status:SetPoint('CENTER', Health)
	self:Tag(Status, '[inomena:dead]')
end)

oUF:SetActiveStyle(styleName)

local pet = oUF:Spawn('pet')
pet:SetPoint('TOPLEFT', addon.units.player, 'BOTTOMLEFT', 0, -5)
addon:PixelPerfect(pet)

-- expose internally
addon.units.pet = pet
