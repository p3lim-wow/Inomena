local _, addon = ...

local backdropMixin = {}
function backdropMixin:SetBackgroundColor(...)
	self.backdropBackground:SetColorTexture(...)
end

function backdropMixin:SetBorderColor(...)
	for _, edge in next, self.backdropEdges do
		edge:SetColorTexture(...)
	end
end

function backdropMixin:SetBorderIgnoreParentAlpha(state)
	for _, edge in next, self.backdropEdges do
		edge:SetIgnoreParentAlpha(state)
	end
end

-- we keep a copy of an unspoiled CreateTexture method for use later
local createTexture = CreateFrame('Frame').CreateTexture
function addon:AddBackdrop(frame, anchor)
	Mixin(frame, backdropMixin)

	frame.backdropEdges = addon:T()

	local borderLeft = createTexture(frame, nil, 'BORDER')
	borderLeft:SetPoint('TOPLEFT', anchor or frame, -1, 1)
	borderLeft:SetPoint('BOTTOMLEFT', anchor or frame, -1, -1)
	frame.backdropEdges:insert(borderLeft)
	addon:PixelPerfect(borderLeft)

	local borderTop = createTexture(frame, nil, 'BORDER')
	borderTop:SetPoint('TOPLEFT', anchor or frame, -1, 1)
	borderTop:SetPoint('TOPRIGHT', anchor or frame, 1, 1)
	frame.backdropEdges:insert(borderTop)
	addon:PixelPerfect(borderTop)

	local borderRight = createTexture(frame, nil, 'BORDER')
	borderRight:SetPoint('TOPRIGHT', anchor or frame, 1, 1)
	borderRight:SetPoint('BOTTOMRIGHT', anchor or frame, 1, -1)
	frame.backdropEdges:insert(borderRight)
	addon:PixelPerfect(borderRight)

	local borderBottom = createTexture(frame, nil, 'BORDER')
	borderBottom:SetPoint('BOTTOMLEFT', anchor or frame, -1, -1)
	borderBottom:SetPoint('BOTTOMRIGHT', anchor or frame, 1, -1)
	frame.backdropEdges:insert(borderBottom)
	addon:PixelPerfect(borderBottom)

	local background = createTexture(frame, nil, 'BACKGROUND')
	background:SetAllPoints(anchor or frame)
	frame.backdropBackground = background
	addon:PixelPerfect(background)

	-- set defaults
	frame:SetBackgroundColor(0, 0, 0, 0.3)
	frame:SetBorderColor(0, 0, 0)
end
