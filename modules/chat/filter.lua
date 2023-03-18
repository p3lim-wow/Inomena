
-- prevent single raid symbols from filling the chat window
local symbols = {
	['{rt1}'] = true, ['{star}'] = true,
	['{rt2}'] = true, ['{circle}'] = true, ['{coin}'] = true,
	['{rt3}'] = true, ['{diamond}'] = true,
	['{rt4}'] = true, ['{triangle}'] = true,
	['{rt5}'] = true, ['{moon}'] = true,
	['{rt6}'] = true, ['{square}'] = true,
	['{rt7}'] = true, ['{cross}'] = true, ['{x}'] = true,
	['{rt8}'] = true, ['{skull}'] = true,
}

ChatFrame_AddMessageEventFilter('CHAT_MSG_SAY', function(self, event, msg, ...)
	if symbols[msg:lower()] then
		return true
	elseif msg == 'Yes chef!' then -- TODO: only filter if it's the cooking event
		return true
	end

	return false, msg, ...
end)
