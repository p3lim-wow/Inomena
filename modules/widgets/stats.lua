local _, addon = ...

-- add framerate and latency above the minimap

local function createText(align)
	local text = addon.widgetMixin.CreateText(UIParent, 12, true)
	text:SetPoint('BOTTOM' .. (align or ''), Minimap, 'TOP' .. (align or ''), 0, addon.SPACING - 1)
	text:SetJustifyH(align or 'CENTER')
	text:SetAlpha(0.8)
	return text
end

local Framerate = createText('LEFT')
C_Timer.NewTicker(0.25, function() -- same interval as FRAMERATE_FREQUENCY
	local fps = GetFramerate()

	local color
	if fps < 40 then
		color = RED_FONT_COLOR_CODE
	elseif fps < 60 then
		color = YELLOW_FONT_COLOR_CODE
	else
		color = GREEN_FONT_COLOR_CODE
	end

	Framerate:SetFormattedText('%s%d|r', color, fps)
end)

local function getLatencyColor(latency)
	if latency > 150 then
		return RED_FONT_COLOR_CODE
	elseif latency > 50 then
		return YELLOW_FONT_COLOR_CODE
	else
		return GREEN_FONT_COLOR_CODE
	end
end

local HomeLatency = createText()
local WorldLatency = createText('RIGHT')
C_Timer.NewTicker(1, function() -- same interval as PERFORMANCEBAR_UPDATE_INTERVAL used to be
	local _, _, home, world = GetNetStats()
	HomeLatency:SetFormattedText('%s%d|r', getLatencyColor(home), home)
	WorldLatency:SetFormattedText('%s%d|r', getLatencyColor(world), world)
end)
