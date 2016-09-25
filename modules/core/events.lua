local E, F, C = unpack(select(2, ...))

local EventHandler = CreateFrame('Frame', C.Name .. 'EventHandler')
local listeners = {}

local function Register(event, func)
	if(type(event) ~= 'string' or type(func) ~= 'function') then
		error('Syntax: RegisterEvent("event", handlerFunction)', 2)
	end

	if(not listeners[event]) then
		listeners[event] = {}
		EventHandler:RegisterEvent(event)
	end

	listeners[event][func] = 1
end

local function Unregister(event, func)
	if(type(event) ~= 'string' or type(func) ~= 'function') then
		error('Syntax: UnregisterEvent("event", handlerFunction)', 2)
	end

	local funcs = listeners[event]
	if(funcs and funcs[func]) then
		funcs[func] = nil

		if(not next(funcs)) then
			listeners[event] = nil
			EventHandler:UnregisterEvent(event)
		end
	end
end

local function Call(self, event, ...)
	local funcs = listeners[event]
	if(funcs) then
		for func in next, funcs do
			if(securecall(func, event, ...) and self == EventHandler) then
				Unregister(event, func)
			end
		end
	end
end

EventHandler:SetScript('OnEvent', Call)

local methods = {}
function methods:RegisterEvent(event, func)
	Register(event, func)
end

function methods:UnregisterEvent(event, func)
	Unregister(event, func)
end

methods.Call = Call

local mt = getmetatable(E)
function mt:__index(event)
	if(listeners[event]) then
		return function(_, ...)
			Call(nil, event, ...)
		end
	else
		return methods[event]
	end
end

function mt:__newindex(event, func)
	Register(event, func)
end
