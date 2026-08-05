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

	local Debuffs
	if self.CreateAuras then
		Debuffs = self:CreateAuras({
			layoutLimit = math.huge,
			growthX = 'RIGHT',
			growthY = 'UP', -- default
			initialAnchor = 'BOTTOMLEFT',
		})
		Debuffs.elementSpacing = addon.SPACING
		Debuffs.lineSpacing = addon.SPACING
		Debuffs.tooltipAnchor = 'ANCHOR_TOPLEFT'
		Debuffs.tooltipOffsetY = 3
		Debuffs.tooltipOffsetX = -1
		Debuffs.showCount = true
		Debuffs.PostCreateButton = addon.unitShared.PostCreateAura
	else -- TODO: remove in 12.1
		Debuffs = self:CreateFrame()
		Debuffs:SetSize(self:GetHeight() * 1.2 * 10, self:GetHeight() * 1.5)
		Debuffs.growthX = 'RIGHT'
		Debuffs.initialAnchor = 'BOTTOMLEFT'
		Debuffs.spacing = addon.SPACING
		Debuffs.PostUpdateButton = addon.unitShared.PostUpdateAura -- for border colors
		Debuffs.CreateButton = addon.unitShared.CreateAura
		self.Debuffs = Debuffs
	end

	Debuffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 4, 5)
	Debuffs.size = self:GetHeight() * 1.2

	if self.CreateAuras then
		-- these are mostly for showing debuffs on co-tank, useful for tank swapping
		Debuffs:AddGroup('HARMFUL', {
			candidateFilters = {
				isBossOrRoleAura = true
			}
		})
	end
end)

oUF:SetActiveStyle(styleName)

local targettarget = oUF:Spawn('targettarget')
targettarget:SetPoint('LEFT', addon.units.target, 'RIGHT', addon.SPACING, 0)
addon:PixelPerfect(targettarget)

-- expose internally
addon.units.targettarget = targettarget
