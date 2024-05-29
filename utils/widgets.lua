local _, addon = ...

local widgetMixin = {}
function widgetMixin:CreateFrame(frameType, template)
	return Mixin(CreateFrame(frameType or 'Frame', nil, self, template), widgetMixin, addon.eventMixin)
end

function widgetMixin:CreateBackdropFrame(frameType)
	local frame = self:CreateFrame(frameType)
	addon:AddBackdrop(frame)
	return frame
end

local statusbarMixin = {}
function statusbarMixin:SetStatusBarColor(r, g, b, a)
	self:GetStatusBarTexture():SetVertexColor(r, g, b, a)
end

function widgetMixin:CreateStatusBar(template)
	local statusbar = Mixin(self:CreateFrame('StatusBar', template), statusbarMixin)
	local texture = statusbar:CreateTexture()
	texture:SetTexelSnappingBias(0)
	texture:SetSnapToPixelGrid(false)
	texture:SetTexture(addon.TEXTURE)
	statusbar:SetStatusBarTexture(texture)
	return statusbar
end

do
	local createTexture = CreateFrame('Frame').CreateTexture
	function widgetMixin:CreateTexture(layer, level)
		local texture = createTexture(self, nil, layer, nil, level)
		-- pixel perfection
		texture:SetTexelSnappingBias(0)
		texture:SetSnapToPixelGrid(false)
		return texture
	end
end

function widgetMixin:CreateBackdropStatusBar(template)
	local statusbar = self:CreateStatusBar(template)
	addon:AddBackdrop(statusbar)
	return statusbar
end

function widgetMixin:CreateText(size)
	if not self.overlayParent then
		-- make sure the text renders above other widgets
		self.overlayParent = CreateFrame('Frame', nil, self)
		self.overlayParent:SetAllPoints() -- needs a size so children are rendered at all
	end

	local text = self.overlayParent:CreateFontString(nil, 'OVERLAY')
	text:SetFont(addon.FONT, size or 16, 'OUTLINE')
	text:SetWordWrap(false)
	return text
end

function widgetMixin:CreateIcon(layer)
	local icon = self:CreateTexture(layer or 'ARTWORK')
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	return icon
end

addon.widgetMixin = widgetMixin

local backdropMixin = {} -- custom "backdrop" with offset edges, instead of inset
function backdropMixin:SetBackgroundColor(...)
	self.backdropBackground:SetColorTexture(...)
end

function backdropMixin:SetBorderColor(...)
	for _, edge in next, self.backdropEdges do
		edge:SetColorTexture(...)
	end
end

function addon:AddBackdrop(frame)
	Mixin(frame, backdropMixin, widgetMixin)
	frame.backdropEdges = {}

	local borderLeft = frame:CreateTexture('BACKGROUND')
	borderLeft:SetPoint('TOPLEFT', -1, 1)
	borderLeft:SetPoint('BOTTOMLEFT', -1, -1)
	borderLeft:SetWidth(1)
	table.insert(frame.backdropEdges, borderLeft)

	local borderRight = frame:CreateTexture('BACKGROUND')
	borderRight:SetPoint('TOPRIGHT', 1, 1)
	borderRight:SetPoint('BOTTOMRIGHT', 1, -1)
	borderRight:SetWidth(1)
	table.insert(frame.backdropEdges, borderRight)

	local borderTop = frame:CreateTexture('BACKGROUND')
	borderTop:SetPoint('TOPLEFT', -1, 1)
	borderTop:SetPoint('TOPRIGHT', 1, 1)
	borderTop:SetHeight(1)
	table.insert(frame.backdropEdges, borderTop)

	local borderBottom = frame:CreateTexture('BACKGROUND')
	borderBottom:SetPoint('BOTTOMLEFT', -1, -1)
	borderBottom:SetPoint('BOTTOMRIGHT', 1, -1)
	borderBottom:SetHeight(1)
	table.insert(frame.backdropEdges, borderBottom)

	local background = frame:CreateTexture('BACKGROUND')
	background:SetAllPoints()
	frame.backdropBackground = background

	-- set defaults
	frame:SetBackgroundColor(0, 0, 0, 0.3)
	frame:SetBorderColor(0, 0, 0)
end
