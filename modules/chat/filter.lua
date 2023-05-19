
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

-- prevent spam when changing talents
local ERR_LEARN_ABILITY = string.split('%s', _G.ERR_LEARN_ABILITY_S)
local ERR_LEARN_PASSIVE = string.split('%s', _G.ERR_LEARN_PASSIVE_S)
local ERR_LEARN_SPELL = string.split('%s', _G.ERR_LEARN_SPELL_S)
local ERR_SPELL_UNLEARNED = string.split('%s', _G.ERR_SPELL_UNLEARNED_S)

ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', function(self, event, msg, ...)
	if msg:sub(1, #ERR_LEARN_ABILITY) == ERR_LEARN_ABILITY then
		return true
	elseif msg:sub(1, #ERR_LEARN_PASSIVE) == ERR_LEARN_PASSIVE then
		return true
	elseif msg:sub(1, #ERR_LEARN_SPELL) == ERR_LEARN_SPELL then
		return true
	elseif msg:sub(1, #ERR_SPELL_UNLEARNED) == ERR_SPELL_UNLEARNED then
		return true
	end

	return false, msg, ...
end)
