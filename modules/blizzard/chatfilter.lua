
-- prevent spam when changing talents

local ERR_LEARN_ABILITY = string.split('%s', ERR_LEARN_ABILITY_S)
local ERR_LEARN_PASSIVE = string.split('%s', ERR_LEARN_PASSIVE_S)
local ERR_LEARN_SPELL = string.split('%s', ERR_LEARN_SPELL_S)
local ERR_SPELL_UNLEARNED = string.split('%s', ERR_SPELL_UNLEARNED_S)

ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_SYSTEM', function(_, _, msg, ...)
	if issecretvalue(msg) then
		return false, msg, ...
	elseif msg:sub(1, #ERR_LEARN_ABILITY) == ERR_LEARN_ABILITY then
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

-- prevent spam during island expeditions

local AZERITE_ISLAND = AZERITE_ISLANDS_XP_GAIN:gsub('%%d', '[0-9]+'):gsub('%%s', '.+')
local AZERITE_HEART = AZERITE_XP_GAIN:gsub('^%%s', '.+'):gsub('%%s', '[0-9,. ]+')
ChatFrameUtil.AddMessageEventFilter('CHAT_MSG_SYSTEM', function(_, _, msg, ...)
	if issecretvalue(msg) then
		return false, msg, ...
	elseif msg:match(AZERITE_ISLAND) then
		return true
	elseif msg:match(AZERITE_HEART) then
		return true
	end

	return false, msg, ...
end)
