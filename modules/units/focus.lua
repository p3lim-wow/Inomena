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

	local Debuffs = self:CreateAuras({
		layoutLimit = math.huge,
		growthX = 'LEFT',
		growthY = 'UP', -- default
		initialAnchor = 'BOTTOMRIGHT',
	})
	Debuffs:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', -4, 5)
	Debuffs.elementSpacing = addon.SPACING
	Debuffs.lineSpacing = addon.SPACING
	Debuffs.showCount = true
	Debuffs.size = self:GetHeight() * 1.2
	Debuffs.tooltipAnchor = 'ANCHOR_TOPRIGHT'
	Debuffs.tooltipOffsetX = 1
	Debuffs.tooltipOffsetY = 3
	Debuffs.PostCreateButton = addon.unitShared.PostCreateAura
	Debuffs:AddGroup('HARMFUL|PLAYER')
end)

oUF:SetActiveStyle(styleName)

local focus = oUF:Spawn('focus')
focus:SetPoint('RIGHT', addon.units.player, 'LEFT', -addon.SPACING, 0)
addon:PixelPerfect(focus)

-- expose internally
addon.units.focus = focus
