local UNAVAILABLE = _G.UNAVAILABLE -- globalstring

local totalElapsed = 0
WorldMapFrame.ScrollContainer.Child:HookScript('OnUpdate', function(self, elapsed)
	if totalElapsed < 0.05 then
		totalElapsed = totalElapsed + elapsed
	else
		totalElapsed = 0

		local x, y, r, g, b
		if self:IsMouseOver() then
			x, y = self:GetParent():GetNormalizedCursorPosition()
			r, g, b = 0, 1, 0
		else
			local position = C_Map.GetPlayerMapPosition(WorldMapFrame:GetMapID(), 'player')
			if position then
				x, y = position:GetXY()
			end

			r, g, b = 1, 1, 0
		end

		if x and y then
			WorldMapFrameTitleText:SetFormattedText('%.2f, %.2f', x * 100, y * 100)
			WorldMapFrameTitleText:SetTextColor(r, g, b)
		else
			WorldMapFrameTitleText:SetText(UNAVAILABLE)
			WorldMapFrameTitleText:SetTextColor(1, 0, 0)
		end
	end
end)
