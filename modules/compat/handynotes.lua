local _, addon = ...

-- remove alt+right-click dropdown from HandyNotes, I only use this addon for its plugins

local hidden = CreateFrame('Frame')
hidden:Hide()

addon:HookAddOn('HandyNotes', function()
	local HandyNotes = LibStub('AceAddon-3.0'):GetAddon('HandyNotes'):GetModule('HandyNotes')
	HandyNotes.ClickHandlerFrame:SetParent(hidden)
end)
