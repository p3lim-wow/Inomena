ConsolidateDB = ConsolidateDB or {}

SLASH_Consolidate1 = '/con'
SLASH_Consolidate2 = '/consolidate'
SlashCmdList.Consolidate = function(str)
	local id = string.match(str, '|Hspell:(%w+)|h')

	if(str and id) then
		if(not ConsolidateDB[id]) then
			ConsolidateDB[id] = true
			print('|cffff8080Consolidate:|r', str, 'is now consolidated')
		else
			ConsolidateDB[id] = false
			print('|cffff8080Consolidate:|r', str, 'is now non-consolidated')
		end
	else
		print('|cffff8080Consolidate:|r Please link a valid buff to filter!')
	end
end

local orig = UnitAura
function UnitAura(unit, ...)
	if(not unit or unit ~= 'player') then return orig(unit, ...) end
	local name, rank, texture, count, dtype, duration, expiration, owner, stealable, consolidate, id = orig(unit, ...)

	local custom = ConsolidateDB[id]
	if(custom or custom == false) then
		consolidate = custom
	end

	return name, rank, texture, count, dtype, duration, expiration, owner, stealable, consolidate, id
end
