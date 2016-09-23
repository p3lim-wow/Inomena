local E, F, C = unpack(select(2, ...))

local Frame
local function AddMessage(body, outgoing)
	if(not outgoing) then
		if(not Frame) then
			Frame = FCF_OpenTemporaryWindow('WHISPER', 'GM')
			ChatFrame_RemoveAllMessageGroups(Frame)
			FCF_SelectDockFrame(SELECTED_CHAT_FRAME)

			F.SkinChatWindow(Frame:GetID())
			local Tab = _G['ChatFrame' .. Frame:GetID() .. 'Tab']
			Tab:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp')
		end

		if(SELECTED_CHAT_FRAME ~= Frame) then
			FCF_StartAlertFlash(Frame)
		end
	end

	local info = ChatTypeInfo.WHISPER
	Frame:AddMessage(body, info.r, info.g, info.b)
end

local link = [[|TInterface\ChatFrame\UI-ChatIcon-Blizz:14:22:-1:-2:32:16:4:26:0:16|t |cff0090ff|HplayerGM:%s|h%s|h|r]]

local inMessage = link .. ': %s'
local outMessage = '|cffa1a1a1@|r' .. inMessage

function E:CHAT_MSG_WHISPER(message, name, _, _, _, flag)
	if(flag == 'GM') then
		if(name == CHAT_MSG_SYSTEM) then
			InomenaLastGM = nil
		else
			InomenaLastGM = name
			ChatEdit_SetLastTellTarget(name, 'WHISPER')
		end

		AddMessage(string.format(inMessage, name, name, message))
	end
end

function E:CHAT_MSG_WHISPER_INFORM(message, name, _, _, _, flag)
	if(flag == 'GM') then
		AddMessage(string.format(outMessage, name, name, message), true)
	end
end

function E:PLAYER_LOGIN()
	if(InomenaLastGM) then
		AddMessage(string.format(GM_CHAT_LAST_SESSION, string.format(link, InomenaLastGM, InomenaLastGM)))
	end
end

hooksecurefunc('FCF_Tab_OnClick', function(self, button)
	if(Frame and button == 'MiddleButton') then
		if(self:GetID() == Frame:GetID()) then
			InomenaLastGM = nil
			Frame = nil
		end
	end
end)

local function MessageFilter(self, _, _, _, _, _, _, flag)
	return self ~= Frame and flag == 'GM'
end

ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER', MessageFilter)
ChatFrame_AddMessageEventFilter('CHAT_MSG_WHISPER_INFORM', MessageFilter)

UIParent:UnregisterEvent('CHAT_MSG_WHISPER')
TicketStatusFrame.Show = function() end
