local _, addon = ...

local FORMAT_DAYS = '%dd'
local FORMAT_HOURS = '%dh'
local FORMAT_MIN = '%dm'
local FORMAT_SEC = '%ds'
local FORMAT_SEC_SHORT = '%1.fs'

function addon:FormatAuraTime(seconds, short)
	-- copy from SharedXML/TimeUtil.lua with modifications to return whole time in compact format
	local output = ''
	local spacer = short and '' or ' '
	if seconds >= 86400 then
		output = output .. FORMAT_DAYS:format(seconds / 86400) .. spacer
		seconds = seconds % 86400
	end
	if seconds >= 3600 then
		output = output .. FORMAT_HOURS:format(seconds / 3600) .. spacer
		seconds = seconds % 3600
	end
	if seconds >= 60 then
		output = output .. FORMAT_MIN:format(seconds / 60) .. spacer
		seconds = seconds % 60
	end
	if seconds > 10 then
		output = output .. FORMAT_SEC:format(seconds)
	elseif seconds > 0 then
		output = output .. FORMAT_SEC_SHORT:format(seconds)
	end

	return short and output or (output .. ' remaining')
end
