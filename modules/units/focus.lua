local _, addon = ...
local oUF = addon.oUF

local styleName = addon.unitPrefix .. 'Focus'
oUF:RegisterStyle(styleName, function(self)
	Mixin(self, addon.widgetMixin)

	self:RegisterForClicks('AnyUp')
	self:SetSize(44, 22)

	local Name = self:CreateText()
	Name:SetPoint('RIGHT')
	Name:SetJustifyH('RIGHT')
	self:Tag(Name, '[inomena:reactioncolor][inomena:name<$|r]')

	local Debuffs = self:CreateFrame()
	Debuffs:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -4, 5)
	Debuffs:SetSize(self:GetHeight() * 1.2 * 10, self:GetHeight() * 1.5)
	Debuffs.growthX = 'LEFT'
	Debuffs.initialAnchor = 'BOTTOMRIGHT'
	Debuffs.filter = 'HARMFUL|PLAYER'
	Debuffs.size = self:GetHeight() * 1.2
	Debuffs.spacing = addon.SPACING
	Debuffs.CreateButton = addon.unitShared.CreateAura
	Debuffs.PostUpdateButton = addon.unitShared.PostUpdateAura
	self.Debuffs = Debuffs
end)

oUF:SetActiveStyle(styleName)

local focus = oUF:Spawn('focus')
focus:SetPoint('RIGHT', addon.units.player, 'LEFT', -addon.SPACING, 0)
addon:PixelPerfect(focus)

-- expose internally
addon.units.focus = focus
