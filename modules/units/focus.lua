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

	local Debuffs
	if self.CreateAuras then
		Debuffs = self:CreateAuras({
			layoutLimit = math.huge,
			growthX = 'LEFT',
			growthY = 'UP', -- default
			initialAnchor = 'BOTTOMRIGHT',
		})
		Debuffs.elementSpacing = addon.SPACING
		Debuffs.lineSpacing = addon.SPACING
		Debuffs.tooltipAnchor = 'ANCHOR_TOPRIGHT'
		Debuffs.tooltipOffsetY = 3
		Debuffs.tooltipOffsetX = 1
		Debuffs.showCount = true
		Debuffs.PostCreateButton = addon.unitShared.PostCreateAura
	else -- TODO: remove in 12.1
		Debuffs = self:CreateFrame()
		Debuffs:SetSize(self:GetHeight() * 1.2 * 10, self:GetHeight() * 1.5)
		Debuffs.growthX = 'LEFT'
		Debuffs.initialAnchor = 'BOTTOMRIGHT'
		Debuffs.filter = 'HARMFUL|PLAYER'
		Debuffs.spacing = addon.SPACING
		Debuffs.PostUpdateButton = addon.unitShared.PostUpdateAura -- for border colors
		Debuffs.CreateButton = addon.unitShared.CreateAura
		self.Debuffs = Debuffs
	end

	Debuffs:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -4, 5)
	Debuffs.size = self:GetHeight() * 1.2

	if self.CreateAuras then
		Debuffs:AddGroup('HARMFUL|PLAYER') -- TBD
	end
end)

oUF:SetActiveStyle(styleName)

local focus = oUF:Spawn('focus')
focus:SetPoint('RIGHT', addon.units.player, 'LEFT', -addon.SPACING, 0)
addon:PixelPerfect(focus)

-- expose internally
addon.units.focus = focus
