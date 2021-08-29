local _, addon = ...

local framerate, localLatency, worldLatency
local function createDisplayString(align)
	local text = UIParent:CreateFontString(nil, 'OVERLAY')
	text:SetPoint('BOTTOM' .. (align or ''), Minimap, 'TOP' .. (align or ''), 0, 5)
	text:SetFontObject('PixelFontNormal')
	text:SetJustifyH(align or 'CENTER')
	text:SetAlpha(0.8)

	return text
end

local function getLatencyColor(latency)
	if latency > 200 then
		return RED_FONT_COLOR_CODE
	elseif latency > 100 then
		return YELLOW_FONT_COLOR_CODE
	else
		return GREEN_FONT_COLOR_CODE
	end
end

local function updateLatency()
	local _, _, localMs, worldMs = GetNetStats()
	localLatency:SetFormattedText('%s%d', getLatencyColor(localMs), localMs)
	worldLatency:SetFormattedText('%s%d', getLatencyColor(worldMs), worldMs)
end

local function updateFramerate()
	local fps, color = GetFramerate()
	if fps < 40 then
		color = RED_FONT_COLOR_CODE
	elseif fps < 60 then
		color = YELLOW_FONT_COLOR_CODE
	else
		color = GREEN_FONT_COLOR_CODE
	end

	framerate:SetFormattedText('%s%d', color, GetFramerate())
end

function addon:PLAYER_LOGIN()
	framerate = createDisplayString('RIGHT')
	localLatency = createDisplayString('LEFT')
	worldLatency = createDisplayString()

	C_Timer.NewTicker(PERFORMANCEBAR_UPDATE_INTERVAL, updateFramerate)
	C_Timer.NewTicker(FRAMERATE_FREQUENCY, updateLatency)
end
