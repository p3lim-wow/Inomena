local _, addon = ...

-- play these on the master channel
function addon:CHAT_MSG_WHISPER()
	PlaySound(SOUNDKIT.TELL_MESSAGE, 'master')
end

function addon:CHAT_MSG_BN_WHISPER()
	PlaySound(SOUNDKIT.TELL_MESSAGE, 'master')
end
