local E, F, C = unpack(select(2, ...))

local Framerate, LocalLatency, WorldLatency
local function CreateDisplayString(align)
	local FontString = UIParent:CreateFontString(nil, 'OVERLAY')
	FontString:SetPoint('BOTTOM' .. (align or ''), Minimap, 'TOP' .. (align or ''), 0, 5)
	FontString:SetFontObject('PixelFontNormal')
	FontString:SetJustifyH(align or 'CENTER')
	FontString:SetAlpha(0.8)

	return FontString
end

local function UpdateFramerate()
	local framerate, color = GetFramerate()
	if(framerate < 40) then
		color = RED_FONT_COLOR_CODE
	elseif(framerate < 60) then
		color = YELLOW_FONT_COLOR_CODE
	else
		color = GREEN_FONT_COLOR_CODE
	end

	Framerate:SetFormattedText('%s%d', color, GetFramerate())
end


local function GetLatencyColor(latency)
	if(latency > 200) then
		return RED_FONT_COLOR_CODE
	elseif(latency > 100) then
		return YELLOW_FONT_COLOR_CODE
	else
		return GREEN_FONT_COLOR_CODE
	end
end

local function UpdateLatency()
	local _, _, localLatency, worldLatency = GetNetStats()
	LocalLatency:SetFormattedText('%s%d', GetLatencyColor(localLatency), localLatency)
	WorldLatency:SetFormattedText('%s%d', GetLatencyColor(worldLatency), worldLatency)
end

function E:PLAYER_LOGIN()
	Framerate = CreateDisplayString('RIGHT')
	LocalLatency = CreateDisplayString('LEFT')
	WorldLatency = CreateDisplayString()

	C_Timer.NewTicker(PERFORMANCEBAR_UPDATE_INTERVAL, UpdateFramerate)
	C_Timer.NewTicker(FRAMERATE_FREQUENCY, UpdateLatency)
end
