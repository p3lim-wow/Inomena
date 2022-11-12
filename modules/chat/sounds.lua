local _, addon = ...

-- whisper notifications on the master channel
function addon:CHAT_MSG_WHISPER()
	PlaySound(3081, 'master') -- SOUNDKIT.TELL_MESSAGE
end

function addon:CHAT_MSG_BN_WHISPER()
	PlaySound(3081, 'master') -- SOUNDKIT.TELL_MESSAGE
end
