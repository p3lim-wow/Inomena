local E, F = unpack(select(2, ...))

local CoordText
local totalElapsed = 0
local function UpdateCoords(self, elapsed)
	if(totalElapsed > 0.1) then
		if(WorldMapScrollFrame:IsMouseOver()) then
			local scale = self:GetEffectiveScale()
			local centerX, centerY = self:GetCenter()
			local width, height = self:GetSize()
			local x, y = GetCursorPosition()

			x = ((x / scale) - (centerX - (width / 2))) / width
			y = (centerY + (height / 2) - (y / scale)) / height

			CoordText:SetFormattedText('%.2f, %.2f', x * 100, y * 100)
			CoordText:SetTextColor(0, 1, 0)
		else
			local x, y = GetPlayerMapPosition('player')
			CoordText:SetFormattedText('%.2f, %.2f', x * 100, y * 100)
			CoordText:SetTextColor(1, 1, 0)
		end

		totalElapsed = 0
	else
		totalElapsed = totalElapsed + elapsed
	end
end

function E:PLAYER_LOGIN()
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint('TOPLEFT', 50, -142)
	ObjectiveTrackerFrame:SetHeight(700)

	ObjectiveTrackerFrame.ClearAllPoints = F.noop
	ObjectiveTrackerFrame.SetPoint = F.noop

	CoordText = WorldMapFrameCloseButton:CreateFontString(nil, nil, 'GameFontNormal')
	CoordText:SetPoint('RIGHT', WorldMapFrameCloseButton, 'LEFT', -30, 0)

	WorldMapDetailFrame:HookScript('OnUpdate', UpdateCoords)

	WorldMapPlayerUpper:EnableMouse(false)
	WorldMapPlayerLower:EnableMouse(false)
end
