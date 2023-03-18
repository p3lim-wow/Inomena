local _, addon = ...

local widgetMixin = {}
function widgetMixin:CreateFrame(frameType)
	return Mixin(CreateFrame(frameType or 'Frame', nil, self), widgetMixin, addon.eventMixin)
end

function widgetMixin:CreateBackdropFrame(frameType)
	local frame = self:CreateFrame(frameType)
	addon:AddBackdrop(frame)
	return frame
end

function widgetMixin:CreateStatusBar()
	local statusbar = self:CreateFrame('StatusBar')
	statusbar:SetStatusBarTexture(addon.TEXTURE)
	return statusbar
end

function widgetMixin:CreateBackdropStatusBar()
	local statusbar = self:CreateStatusBar()
	addon:AddBackdrop(statusbar)
	return statusbar
end

function widgetMixin:CreateText(size)
	if not self.overlayParent then
		-- make sure the text renders above other layouts
		self.overlayParent = CreateFrame('Frame', nil, self)
		self.overlayParent:SetAllPoints() -- needs a size so children are rendered at all
	end

	local text = self.overlayParent:CreateFontString(nil, 'OVERLAY')
	text:SetFont(addon.FONT, size or 16, 'OUTLINE')
	text:SetWordWrap(false)
	return text
end

function widgetMixin:CreateIcon(layer)
	local icon = self:CreateTexture(nil, layer or 'ARTWORK')
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	return icon
end

addon.widgetMixin = widgetMixin

local FORMAT_DAYS = '%dd'
local FORMAT_HOURS = '%dh'
local FORMAT_MIN = '%dm'
local FORMAT_SEC = '%ds'

function addon:FormatAuraTime(seconds)
	-- copy from SharedXML/TimeUtil.lua with modifications to return whole time in compact format
	local output = ''
	if seconds >= 86400 then
		output = output .. FORMAT_DAYS:format(seconds / 86400) .. ' '
		seconds = seconds % 86400
	end
	if seconds >= 3600 then
		output = output .. FORMAT_HOURS:format(seconds / 3600) .. ' '
		seconds = seconds % 3600
	end
	if seconds >= 60 then
		output = output .. FORMAT_MIN:format(seconds / 60) .. ' '
		seconds = seconds % 60
	end
	if seconds > 0 then
		output = output .. FORMAT_SEC:format(seconds)
	end
	return output .. ' remaining'
end
