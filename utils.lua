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

local hidden = CreateFrame('Frame')
hidden:Hide()

function addon:Hide(object)
	if type(object) == 'string' then
		object = _G[object]
	end

	object:SetParent(hidden)

	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
end

function addon:RegisterSlash(...)
	local name = addon.NAME .. 'Slash' .. math.random()

	local numArgs = select('#', ...)
	local callback = select(numArgs, ...)
	if type(callback) ~= 'function' or numArgs < 2 then
		error('Syntax: RegisterSlash("/slash1"[, "/slash2"], slashFunction)')
	end

	for index = 1, numArgs - 1 do
		local str = select(index, ...)
		if type(str) ~= 'string' then
			error('Syntax: RegisterSlash("/slash1"[, "/slash2"], slashFunction)')
		end

		_G['SLASH_' .. name .. index] = str
	end

	SlashCmdList[name] = callback
end

local NPC_ID_PATTERN = '%w+%-.-%-.-%-.-%-.-%-(.-)%-'
function addon:GetNPCID(unit)
	if unit and UnitExists(unit) then
		local npcGUID = UnitGUID(unit)
		return npcGUID and (tonumber(npcGUID:match(NPC_ID_PATTERN)))
	end
end
