local E, F = unpack(select(2, ...))

function F:RegisterSlash(...)
	local name = 'InomenaSlash' .. math.floor(GetTime())

	local numArgs = select('#', ...)
	local func = select(numArgs, ...)
	if(type(func) ~= 'function' or numArgs < 2) then
		error('Syntax: RegisterSlash("/slash1"[, "/slash2"], slashFunction)')
	end

	for index = 1, numArgs - 1 do
		local str = select(index, ...)
		if(type(str) ~= 'string') then
			error('Syntax: RegisterSlash("/slash1"[, "/slash2"], slashFunction)')
		end

		_G['SLASH_' .. name .. index] = str
	end

	SlashCmdList[name] = func
end

function F:noop()
end
