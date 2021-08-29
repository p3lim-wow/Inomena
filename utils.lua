local _, addon = ...

function addon:FormatShortTime(seconds)
	-- copy from SharedXML/TimeUtil.lua with modifications to return whole time in compact format
	local output = ''
	if seconds >= 86400 then
		output = ('%s%dd'):format(output, seconds / 86400)
		seconds = seconds % 86400
	end
	if seconds >= 3600 then
		output = ('%s%dh'):format(output, seconds / 3600)
		seconds = seconds % 3600
	end
	if seconds >= 60 then
		output = ('%s%dm'):format(output, seconds / 60)
		seconds = seconds % 60
	end
	if seconds > 0 then
		output = ('%s%ds'):format(output, seconds)
	end
	return output
end

function addon:HookAddOn(addonName, callback)
	self:RegisterEvent('ADDON_LOADED', function(self, name)
		if name == addonName then
			callback()
			return true
		elseif name == addon.NAME and IsAddOnLoaded(addonName) then
			callback()
			return true
		end
	end)
end

