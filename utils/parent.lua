local addonName, addon = ...

-- as long as we anchor all of our stuff to this frame and use our widget mixins,
-- everything will be pixel perfect. downside is we'll need to handle shown state.
local parent = CreateFrame('Frame', nil, WorldFrame)
parent:SetAllPoints()

-- update parent scale whenever UI scale changes
function addon:UI_SCALE_CHANGED()
	local _, screenHeight = GetPhysicalScreenSize()
	parent:SetIgnoreParentScale(true)
	parent:SetScale(768 / screenHeight)
end

-- let UIParent manage visibility (e.g. make parent respect Alt+Z)
-- UIParentBottomManagedFrameContainer:AddManagedFrame(parent) -- this taints

-- respect alt+z
UIParent:HookScript('OnShow', function()
	parent:SetAlpha(1)
end)
UIParent:HookScript('OnHide', function()
	parent:SetAlpha(0)
end)

-- expose for our other stuff
addon.parent = parent

-- other scenarios where we'll want to hide stuff
local games = {
	[137924] = true, -- Shell Game
	[214997] = true, -- Hearthstone Game Table
}

local activeGame
addon:RegisterUnitEvent('UNIT_ENTERING_VEHICLE', 'player', function(_, _, _, _, _, guid)
	local npcID = addon:ExtractIDFromGUID(guid)
	if games[npcID or 0] then
		addon:DeferMethod(parent, 'Hide', parent)
		activeGame = true
	end
end)

addon:RegisterUnitEvent('UNIT_EXITING_VEHICLE', 'player', function()
	if activeGame then
		addon:DeferMethod(parent, 'Show', parent)
		activeGame = false
	end
end)
