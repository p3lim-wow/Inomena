local _, addon = ...

local BACKDROP = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	edgeFile = [[Interface\ChatFrame\ChatFrameBackground]],
	edgeSize = 1,
}

local backdropMixin = {}
function backdropMixin:CreateBackdrop(backdropAlpha, borderAlpha)
	if not self.SetBackdrop then
		Mixin(self, BackdropTemplateMixin)
	end

	self:SetBackdrop(BACKDROP)
	self:SetBackdropColor(0, 0, 0, backdropAlpha or 0.5)
	self:SetBackdropBorderColor(0, 0, 0, borderAlpha or 1)
end

addon.mixins.backdrop = backdropMixin
