local _, addon = ...

local widgetMixin = {}

do
	local frameMixin = {}
	function frameMixin:SetThrottledUpdate(interval, callback)
		-- I wish they'd add :SetOnUpdateInterval
		if interval and callback then
			local total = 0
			self:SetScript('OnUpdate', function(_, elapsed)
				total = total + elapsed
				if total > interval then
					total = 0
					callback(self)
				end
			end)
		else
			self:SetScript('OnUpdate', nil)
		end
	end

	local KEY_DIRECTION_CVAR = 'ActionButtonUseKeyDown'
	local function updateKeyDirection(self)
		-- TODO: support other clicks than Any
		if C_CVar.GetCVarBool(KEY_DIRECTION_CVAR) then
			self:RegisterForClicks('AnyDown')
		else
			self:RegisterForClicks('AnyUp')
		end
	end

	function frameMixin:UpdateClickDirection(cvar)
		if cvar == KEY_DIRECTION_CVAR then
			addon:Defer(updateKeyDirection, self)
		end
	end

	local function createFrame(frameType, ...)
		local frame = Mixin(CreateFrame(frameType, ...), widgetMixin, addon.eventMixin, frameMixin)
		if frameType:match('Button') then
			frame:RegisterEvent('CVAR_UPDATE', frame.UpdateClickDirection)
			frame:UpdateClickDirection(KEY_DIRECTION_CVAR) -- force update on creation
		end

		return frame
	end

	local function createBackdropFrame(...)
		local frame = createFrame(...)
		frame:AddBackdrop()
		return frame
	end

	function widgetMixin:CreateFrame(frameType, template)
		return createFrame(frameType or 'Frame', nil, self, template)
	end

	function widgetMixin:CreateBackdropFrame(frameType, template)
		return createBackdropFrame(frameType or 'Frame', nil, self, template)
	end

	function addon:CreateFrame(...)
		return createFrame(...)
	end

	function addon:CreateBackdropFrame(...)
		return createBackdropFrame(...)
	end
end

do
	local statusBarMixin = {}
	function statusBarMixin:SetStatusBarColorFromBoolean(...)
		self:SetStatusBarColor(C_CurveUtil.EvaluateColorFromBoolean(...):GetRGB())
	end

	function statusBarMixin:SetDefaultOptions()
		local texture = self:CreateTexture()
		texture:SetTexture(addon.TEXTURE)
		self:SetStatusBarTexture(texture)
	end

	widgetMixin.statusBarMixin = statusBarMixin

	function widgetMixin:CreateStatusBar(template)
		local statusBar = Mixin(self:CreateFrame('StatusBar', template), statusBarMixin)
		statusBar:SetDefaultOptions()
		return statusBar
	end

	function widgetMixin:CreateBackdropStatusBar(template)
		local statusBar = self:CreateStatusBar(template)
		statusBar:AddBackdrop()
		statusBar:SetBackgroundColor(0, 0, 0, 0.7) -- default is hard to see on light backgrounds
		return statusBar
	end
end

do
	local textureMixin = {}
	function textureMixin:SetColorTextureFromBoolean(...)
		self:SetColorTexture(1, 1, 1) -- reset color texture first
		self:SetVertexColor(C_CurveUtil.EvaluateColorFromBoolean(...):GetRGB())
	end

	local createTexture = CreateFrame('Frame').CreateTexture
	function widgetMixin:CreateTexture(layer, level)
		local texture = Mixin(createTexture(self, nil, layer, nil, level), textureMixin)
		addon:PixelPerfect(texture)
		return texture
	end

	local iconMixin = {}
	function iconMixin:SetDefaultOptions()
		self:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	end

	widgetMixin.iconMixin = iconMixin

	function widgetMixin:CreateIcon(layer, level)
		local icon = Mixin(self:CreateTexture(layer, level), iconMixin)
		icon:SetDefaultOptions()
		return icon
	end
end

do
	local textMixin = {}
	function textMixin:SetFontSize(size)
		self:SetFont(addon.FONT, size or 16, 'SLUG,OUTLINE')
	end

	function textMixin:SetFrameLevel(level)
		self:GetParent():SetFrameLevel(level)
	end

	function textMixin:SetDefaultOptions(size)
		self:SetFontSize(size)
		self:SetWordWrap(false)
	end

	widgetMixin.textMixin = textMixin

	function widgetMixin:CreateText(size, noOverlay)
		local parent
		if noOverlay then
			parent = self
		else
			if not self.overlayParent then
				-- make sure text renders above other widgets
				self.overlayParent = CreateFrame('Frame', nil, self)
				self.overlayParent:SetAllPoints() -- needs a size so children can render
			end

			parent = self.overlayParent
		end

		local text = Mixin(parent:CreateFontString(nil, 'OVERLAY'), textMixin)
		text:SetDefaultOptions(size)
		return text
	end
end

do
	local cooldownMixin = {}
	function cooldownMixin:SetTimeFont(size)
		self:GetCountdownFontString():SetFont(addon.FONT, size or 16, 'SLUG,OUTLINE')
	end

	function cooldownMixin:ClearTimePoints()
		self:GetCountdownFontString():ClearAllPoints()
	end

	function cooldownMixin:SetTimePoint(...)
		self:GetCountdownFontString():SetPoint(...)
	end

	function cooldownMixin:SetIgnoreGlobalCooldown(state)
		self:SetMinimumCountdownDuration(state and 1500 or 0)
	end

	function cooldownMixin:SetDefaultOptions()
		self:SetDrawEdge(false)
		self:SetDrawBling(false)
		self:SetSwipeColor(0, 0, 0, 0.9)
		self:SetTimeFont()
		self:SetIgnoreGlobalCooldown(true)
		self:SetCountdownFormatter(addon.formatters.Countdown)
	end

	widgetMixin.cooldownMixin = cooldownMixin

	function widgetMixin:CreateCooldown(anchor)
		local cooldown = Mixin(widgetMixin.CreateFrame(self, 'Cooldown', 'CooldownFrameTemplate'), cooldownMixin)
		cooldown:SetAllPoints(anchor or self)
		cooldown:SetDefaultOptions()
		return cooldown
	end

	function addon:CreateCooldown(parent, anchor)
		return widgetMixin.CreateCooldown(parent, anchor)
	end
end

do
	local backdropMixin = {}
	function backdropMixin:SetBackgroundColor(...)
		self.backdropBackground:SetVertexColor(...)
	end

	function backdropMixin:SetBorderColor(...)
		for _, edge in next, self.backdropEdges do
			edge:SetVertexColor(...)
		end
	end

	function backdropMixin:SetBorderAlpha(...)
		for _, edge in next, self.backdropEdges do
			edge:SetAlpha(...)
		end
	end

	function backdropMixin:SetBorderIgnoreParentAlpha(state)
		for _, edge in next, self.backdropEdges do
			edge:SetIgnoreParentAlpha(state)
		end
	end

	function widgetMixin:AddBackdrop(anchor)
		Mixin(self, backdropMixin)

		self.backdropEdges = addon:T()

		local borderLeft = widgetMixin.CreateTexture(self, 'BORDER')
		borderLeft:SetPoint('TOPLEFT', anchor or self, -1, 1)
		borderLeft:SetPoint('BOTTOMLEFT', anchor or self, -1, -1)
		borderLeft:SetTexture(addon.TEXTURE)
		borderLeft:SetWidth(1)
		self.backdropEdges:insert(borderLeft)

		local borderRight = widgetMixin.CreateTexture(self, 'BORDER')
		borderRight:SetPoint('TOPRIGHT', anchor or self, 1, 1)
		borderRight:SetPoint('BOTTOMRIGHT', anchor or self, 1, -1)
		borderRight:SetTexture(addon.TEXTURE)
		borderRight:SetWidth(1)
		self.backdropEdges:insert(borderRight)

		local borderTop = widgetMixin.CreateTexture(self, 'BORDER')
		borderTop:SetPoint('TOPLEFT', anchor or self, -1, 1)
		borderTop:SetPoint('TOPRIGHT', anchor or self, 1, 1)
		borderTop:SetTexture(addon.TEXTURE)
		borderTop:SetHeight(1)
		self.backdropEdges:insert(borderTop)

		local borderBottom = widgetMixin.CreateTexture(self, 'BORDER')
		borderBottom:SetPoint('BOTTOMLEFT', anchor or self, -1, -1)
		borderBottom:SetPoint('BOTTOMRIGHT', anchor or self, 1, -1)
		borderBottom:SetTexture(addon.TEXTURE)
		borderBottom:SetHeight(1)
		self.backdropEdges:insert(borderBottom)

		local background = widgetMixin.CreateTexture(self, 'BACKGROUND')
		background:SetAllPoints(anchor or self)
		background:SetTexture(addon.TEXTURE)
		self.backdropBackground = background

		-- set defaults
		self:SetBackgroundColor(0, 0, 0, 0.3)
		self:SetBorderColor(0, 0, 0)
	end

	function addon:AddBackdrop(parent, anchor)
		widgetMixin.AddBackdrop(parent, anchor)
	end
end

do
	local outlineMixin = {}
	function outlineMixin:SetColor(...)
		for _, edge in next, self.edges do
			edge:SetColorTexture(...)
		end
	end

	function widgetMixin:CreateOutline()
		local Outline = Mixin(widgetMixin.CreateBackdropFrame(self), outlineMixin)
		Outline:SetPoint('TOPLEFT', -4, 4)
		Outline:SetPoint('TOPRIGHT', 4, 4)
		Outline:SetPoint('BOTTOM', 0, -4)
		Outline:SetFrameStrata('BACKGROUND')
		Outline:SetBackgroundColor(0, 0, 0, 0)
		Outline.edges = {}

		local Left = Outline:CreateTexture()
		Left:SetPoint('TOPLEFT')
		Left:SetPoint('BOTTOMLEFT')
		Left:SetPoint('RIGHT', self, 'LEFT')
		Outline.edges.Left = Left

		local Right = Outline:CreateTexture()
		Right:SetPoint('TOPRIGHT')
		Right:SetPoint('BOTTOMRIGHT')
		Right:SetPoint('LEFT', self, 'RIGHT')
		Outline.edges.Right = Right

		local Top = Outline:CreateTexture()
		Top:SetPoint('TOPLEFT')
		Top:SetPoint('TOPRIGHT')
		Top:SetPoint('BOTTOM', self, 'TOP')
		Outline.edges.Top = Top

		local Bottom = Outline:CreateTexture()
		Bottom:SetPoint('BOTTOMLEFT')
		Bottom:SetPoint('BOTTOMRIGHT')
		Bottom:SetPoint('TOP', self, 'BOTTOM')
		Outline.edges.Bottom = Bottom

		return Outline
	end

	function addon:CreateOutline(parent)
		return widgetMixin.CreateOutline(parent)
	end
end

-- expose internally

addon.widgetMixin = widgetMixin
