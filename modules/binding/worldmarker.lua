local _, addon = ...

-- create a reference frame that is shared between the two binds,
-- we'll use this to store an attribute with the last marker index,
-- which lets us reset the cycle when clearing all markers
local secureHeader = CreateFrame('Frame', nil, UIParent, 'SecureHandlerBaseTemplate')

-- create a secure macro button to place markers on the cursor
local placemarker = addon:BindButton('PlaceMarker', 'CTRL-T', 'SecureActionButtonTemplate')
placemarker:SetAttribute('type', 'macro')

-- wrap PreClick so we can modify the macro securely before it is executed
SecureHandlerWrapScript(placemarker, 'PreClick', secureHeader, [[
	-- set the current marker index based on the previous one plus one, cycling it with a modulo
	owner:SetAttribute('markerindex', (owner:GetAttribute('markerindex') or 0) % 8 + 1)
	self:SetAttribute('macrotext', '/worldmarker [@cursor] ' .. owner:GetAttribute('markerindex'))
]])

-- create a secure macro button to clear all markers and reset the cycle
local clearmarkers = addon:BindButton('ClearMarkers', 'CTRL-SHIFT-T', 'SecureActionButtonTemplate')
clearmarkers:SetAttribute('type', 'macro')
clearmarkers:SetAttribute('macrotext', '/clearworldmarker 0')

SecureHandlerWrapScript(clearmarkers, 'PreClick', secureHeader, [[
	owner:SetAttribute('markerindex', 0)
]])
