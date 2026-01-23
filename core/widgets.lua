local _, addon = ...

local widgetMixin = {}
function widgetMixin:CreateFrame(frameType, template)
	return Mixin(addon:CreateFrame(frameType or 'Frame', nil, self, template), widgetMixin) -- extending Dashi
end

function widgetMixin:CreateBackdropFrame(frameType, template)
	local frame = self:CreateFrame(frameType, template)
	frame:AddBackdrop()
	return frame
end

do
	local statusBarMixin = {}
	function statusBarMixin:SetStatusBarColor(...)
		self:GetStatusBarTexture():SetVertexColor(...)
	end

	function statusBarMixin:SetStatusBarColorFromBoolean(...)
		self:GetStatusBarTexture():SetVertexColorFromBoolean(...)
	end

	function widgetMixin:CreateStatusBar(template)
		local statusBar = Mixin(self:CreateFrame('StatusBar', template), statusBarMixin)
		local texture = statusBar:CreateTexture()
		texture:SetTexture(addon.TEXTURE)
		statusBar:SetStatusBarTexture(texture)

		return statusBar
	end

	function widgetMixin:CreateBackdropStatusBar(template)
		local statusBar = self:CreateStatusBar(template)
		statusBar:AddBackdrop()
		statusBar:SetBackgroundColor(0, 0, 0, 0.5) -- default is hard to see on light backgrounds
		return statusBar
	end
end

do
	local textureMixin = {}
	function textureMixin:SetColorTextureFromBoolean(...)
		self:SetColorTexture(1, 1, 1) -- reset color texture first
		self:SetVertexColorFromBoolean(...)
	end

	local createTexture = CreateFrame('Frame').CreateTexture
	function widgetMixin:CreateTexture(layer, level)
		local texture = Mixin(createTexture(self, nil, layer, nil, level), textureMixin)
		addon:PixelPerfect(texture)
		return texture
	end

	function widgetMixin:CreateIcon(layer, level)
		local icon = self:CreateTexture(layer, level)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		return icon
	end
end

do
	local textMixin = {}
	function textMixin:SetFontSize(size)
		self:SetFont(addon.FONT, size or 16, 'OUTLINE')
	end

	function textMixin:SetFrameLevel(level)
		self:GetParent():SetFrameLevel(level)
	end

	function widgetMixin:CreateText(size)
		if not self.overlayParent then
			-- make sure text renders above other widgets
			self.overlayParent = CreateFrame('Frame', nil, self)
			self.overlayParent:SetAllPoints() -- needs a size so children can render
		end

		local text = Mixin(self.overlayParent:CreateFontString(nil, 'OVERLAY'), textMixin)
		text:SetFontSize(size)
		text:SetWordWrap(false)
		return text
	end
end

function widgetMixin:AddBackdrop(...)
	addon:AddBackdrop(self, ...)
end

-- expose internally

function addon:CreateFrame(...)
	return Mixin(CreateFrame(...), widgetMixin, addon.eventMixin)
end

addon.widgetMixin = widgetMixin
