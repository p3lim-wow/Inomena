local _, Inomena = ...

local addon = CreateFrame('Frame')
addon:SetScript('OnEvent', function(self, event, ...) self[event](...) end)

local metatable = {
	__call = function(funcs, self, ...)
		for _, func in pairs(funcs) do
			func(self, ...)
		end
	end
}

Inomena.Initialize = {}
Inomena.RegisterEvent = function(event, method)
	local current = addon[event]
	if(current and method) then
		if(type(current) == 'function') then
			addon[event] = setmetatable({current, method}, metatable)
		else
			for _, func in pairs(current) do
				if(func == method) then return end
			end

			table.insert(current, method)
		end
	else
		addon[event] = method
		addon:RegisterEvent(event)
	end
end

function SlashCmdList.Inomena()
	for type, func in pairs(Inomena.Initialize) do
		func()
	end

	print('|cffff6000Inomena:|r Successfully initialized settings')
end

SLASH_Inomena1 = '/init'
