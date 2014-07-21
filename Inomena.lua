local __, Inomena = ...

local handler = CreateFrame('Frame')
handler:SetScript('OnEvent', function(self, event, ...) self[event](...) end)

local metatable = {
	__call = function(funcs, self, ...)
		for __, func in next, funcs do
			func(self, ...)
		end
	end
}

Inomena.Initialize = {}
Inomena.RegisterEvent = function(event, method)
	local current = handler[event]
	if(current and method) then
		if(type(current) == 'function') then
			handler[event] = setmetatable({current, method}, metatable)
		else
			for __, func in next, current do
				if(func == method) then return end
			end

			table.insert(current, method)
		end
	else
		handler[event] = method
		handler:RegisterEvent(event)
	end
end

function SlashCmdList.Inomena()
	for type, func in next, Inomena.Initialize do
		func()
	end

	print('|cffff6000Inomena:|r Successfully initialized settings')
end

SLASH_Inomena1 = '/init'
