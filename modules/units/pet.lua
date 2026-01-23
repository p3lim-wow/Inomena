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
