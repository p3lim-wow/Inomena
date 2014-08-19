local _, Inomena = ...

local handler = CreateFrame('Frame')
handler:SetScript('OnEvent', function(self, event, ...) self[event](...) end)

local metatable = {
	__call = function(funcs, self, ...)
		for _, func in next, funcs do
			func(self, ...)
		end
	end
}

Inomena.RegisterEvent = function(event, method)
	local current = handler[event]
	if(current and method) then
		if(type(current) == 'function') then
			handler[event] = setmetatable({current, method}, metatable)
		else
			for _, func in next, current do
				if(func == method) then return end
			end

			table.insert(current, method)
		end
	else
		handler[event] = method
		handler:RegisterEvent(event)
	end
end

Inomena.null = function() end

Inomena.WoD = select(4, GetBuildInfo()) >= 6e4
