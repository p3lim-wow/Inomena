
-- replace world map title text with coordinates

local function updateCoordinates(canvas)
	local x, y, suffix
	local r, g, b

	if canvas:IsMouseOver() then
		x, y = canvas:GetParent():GetNormalizedCursorPosition()
		r, g, b = 0, 1, 0
	else
		local position = addon:GetPlayerPosition(WorldMapFrame:GetMapID())
		if not position then
			local playerMapID = addon:GetPlayerMapID()
			if playerMapID then
				position = addon:GetPlayerPosition(playerMapID)

				local mapInfo = C_Map.GetMapInfo(playerMapID)
				if mapInfo and mapInfo.name then
					suffix = ' |cffababab(in ' .. mapInfo.name .. ')|r'
				end
			end
		end

		if position then
			x, y = position:GetXY()
		end
		r, g, b = 1, 1, 0
	end

	if x and y then
		WorldMapFrameTitleText:SetFormattedText('%.2f, %.2f%s', x * 100, y * 100, suffix or '')
		WorldMapFrameTitleText:SetTextColor(r, g, b)
	else
		WorldMapFrameTitleText:SetText(UNAVAILABLE)
		WorldMapFrameTitleText:SetTextColor(1, 0, 0)
	end
end

local totalElapsed = 0
WorldMapFrame.ScrollContainer.Child:HookScript('OnUpdate', function(self, elapsed)
	if totalElapsed < 0.05 then
		totalElapsed = totalElapsed + elapsed
	else
		totalElapsed = 0

		updateCoordinates(self)
	end
end)
