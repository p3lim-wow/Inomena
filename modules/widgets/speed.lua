local PAPERDOLL_STATCATEGORIES = _G.PAPERDOLL_STATCATEGORIES -- FrameXML/PaperDollFrame.lua

-- add movement speed back to the CharacterFrame
hooksecurefunc('PaperDollFrame_SetMovementSpeed', function(self)
	self:Show()
end)

table.insert(PAPERDOLL_STATCATEGORIES[1].stats, {stat = 'MOVESPEED'})
