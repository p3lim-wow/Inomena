local E, F, C = unpack(select(2, ...))

local BfA = C.BfA

local CoordText
local function UpdateCoords(self)
	local x, y, r, g, b
	if(self:IsMouseOver()) then
		x, y = self:GetParent():GetNormalizedCursorPosition()
		r, g, b = 0, 1, 0
	else
		local position = C_Map.GetPlayerMapPosition(WorldMapFrame:GetMapID(), 'player')
		if(position) then
			x, y = position:GetXY()
		end

		r, g, b = 1, 1, 0
	end

	if(x and y) then
		CoordText:SetFormattedText('%.2f, %.2f', x * 100, y * 100)
		CoordText:SetTextColor(r, g, b)
	else
		CoordText:SetText(UNAVAILABLE)
		CoordText:SetTextColor(1, 0, 0)
	end
end

local totalElapsed = 0
local function OnUpdate(self, elapsed)
	if(totalElapsed > 0.05) then
		UpdateCoords(self)

		totalElapsed = 0
	else
		totalElapsed = totalElapsed + elapsed
	end
end

function E:PLAYER_LOGIN()
	CoordText = WorldMapFrameCloseButton:CreateFontString(C.Name .. 'Coordinates', nil, 'GameFontNormal')
	CoordText:SetPoint('RIGHT', WorldMapFrameCloseButton, 'LEFT', -30, 0)

	WorldMapFrame.ScrollContainer.Child:HookScript('OnUpdate', OnUpdate)
end
