local _, addon = ...

local validator = CreateFrame('Frame')
local function isEvent(event)
	-- check if `event` is actually an event
	if pcall(validator.RegisterEvent, validator, event) then
		validator:UnregisterEvent(event)
		return true
	end
end

local callbacks = {}
local eventHandler = CreateFrame('Frame')

local eventMixin = {}
function eventMixin:RegisterEvent(event, callback)
	assert(isEvent(event), 'arg1 must be an event')
	assert(type(callback) == 'function', 'arg2 must be a function')

	if not callbacks[event] then
		callbacks[event] = {}
	end

	table.insert(callbacks[event], {
		callback = callback,
		owner = self,
	})

	if not eventHandler:IsEventRegistered(event) then
		eventHandler:RegisterEvent(event)
	end
end

function eventMixin:UnregisterEvent(event, callback)
	assert(isEvent(event), 'arg1 must be an event')
	assert(type(callback) == 'function', 'arg2 must be a function')

	for index, data in next, callbacks[event] do
		if data.owner == self and data.callback == callback then
			callbacks[event][index] = nil
			break
		end
	end

	if #callbacks[event] == 0 then
		eventHandler:UnregisterEvent(event)
	end
end

function eventMixin:TriggerEvent(event, ...)
	if callbacks[event] then
		for _, data in next, callbacks[event] do
			if data.callback(data.owner, ...) then
				-- callbacks can unregister themselves by returning positively
				eventMixin.UnregisterEvent(data.owner, event, data.callback)
			end
		end
	end
end

eventHandler:SetScript('OnEvent', function(_, event, ...)
	eventMixin:TriggerEvent(event, ...)
end)

-- expose the mixin
addon.mixins.event = eventMixin

-- facilitate anonymous event registration and triggering
addon = setmetatable(addon, {
	__index = function(t, key)
		if isEvent(key) then
			-- addon:EVENT_NAME([arg1[, ...])
			return function(_, ...)
				eventMixin.TriggerEvent(t, key, ...)
			end
		else
			-- default table behaviour
			return rawget(t, key)
		end
	end,
	__newindex = function(t, key, value)
		if isEvent(key) then
			-- function addon:EVENT_NAME(...) end
			eventMixin.RegisterEvent(t, key, value)
		else
			-- default table behaviour
			rawset(t, key, value)
		end
	end,
})

Mixin(addon, eventMixin)
