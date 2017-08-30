local E, F, C = unpack(select(2, ...))

function E:CHAT_MSG_WHISPER()
	PlaySound(SOUNDKIT.TELL_MESSAGE, 'master')
end
function E:CHAT_MSG_BN_WHISPER()
	PlaySound(SOUNDKIT.TELL_MESSAGE, 'master')
end
function E:CHAT_MSG_BN_CONVERSATION()
	PlaySound(SOUNDKIT.TELL_MESSAGE, 'master')
end
