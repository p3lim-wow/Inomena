local _, addon = ...

local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS or 10 -- FrameXML/ChatFrame.lua

-- faster scrolling
local function onMouseWheel(chatFrame, direction)
	if direction > 0 then
		if IsShiftKeyDown() then
			chatFrame:ScrollToTop()
		elseif IsControlKeyDown() then
			chatFrame:PageUp()
		else
			chatFrame:ScrollUp()
		end
	else
		if IsShiftKeyDown() then
			chatFrame:ScrollToBottom()
		elseif IsControlKeyDown() then
			chatFrame:PageDown()
		else
			chatFrame:ScrollDown()
		end
	end
end

function addon:PLAYER_LOGIN()
	for index = 1, NUM_CHAT_WINDOWS do
		_G['ChatFrame' .. index]:SetScript('OnMouseWheel', onMouseWheel)
	end
end
