local _, addon = ...
local oUF = addon.oUF

local styleName = addon.unitPrefix .. 'TargetTarget'
oUF:RegisterStyle(styleName, function(self)
	Mixin(self, addon.widgetMixin)

	self:RegisterForClicks('AnyUp')
	self:SetSize(44, 22)

	local Name = self:CreateText()
	Name:SetPoint('LEFT')
	Name:SetJustifyH('LEFT')
	self:Tag(Name, '[inomena:reactioncolor][inomena:name<$|r]')

	local Debuffs = self:CreateFrame()
	Debuffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 4, 5)
	Debuffs:SetSize(self:GetHeight() * 1.2 * 10, self:GetHeight() * 1.5)
	Debuffs.growthX = 'RIGHT'
	Debuffs.initialAnchor = 'BOTTOMLEFT'
	Debuffs.size = self:GetHeight() * 1.2
	Debuffs.spacing = addon.SPACING
	Debuffs.CreateButton = addon.unitShared.CreateAura
	Debuffs.PostUpdateButton = addon.unitShared.PostUpdateAura
	self.Debuffs = Debuffs
end)

oUF:SetActiveStyle(styleName)

local targettarget = oUF:Spawn('targettarget')
targettarget:SetPoint('LEFT', addon.units.target, 'RIGHT', addon.SPACING, 0)
addon:PixelPerfect(targettarget)

-- expose internally
addon.units.targettarget = targettarget
