local E, F, C = unpack(select(2, ...))

function E:CHAT_MSG_WHISPER()
	PlaySound('TellMessage', 'master')
end
function E:CHAT_MSG_BN_WHISPER()
	PlaySound('TellMessage', 'master')
end
function E:CHAT_MSG_BN_CONVERSATION()
	PlaySound('TellMessage', 'master')
end
