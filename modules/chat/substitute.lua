-- replace "%x" with the player's position as a waypoint hyperlink
local origEditbox, origMessage
hooksecurefunc('ChatEdit_ParseText', function(editbox, send)
	if send == 1 then
		local msg = editbox:GetText()
		if msg:find('%%x') then -- X marks the spot
			-- store original message
			origEditbox = editbox
			origMessage = msg

			-- store any existing waypoints
			local waypoint = C_Map.HasUserWaypoint() and C_Map.GetUserWaypoint()

			-- generate a new waypoint
			local mapID = C_Map.GetBestMapForUnit('player')
			local position = C_Map.GetPlayerMapPosition(mapID, 'player')
			C_Map.SetUserWaypoint(UiMapPoint.CreateFromVector2D(mapID, position))

			-- substitute message
			editbox:SetText(msg:gsub('%%x', C_Map.GetUserWaypointHyperlink()))

			-- remove the waypoint
			C_Map.ClearUserWaypoint()

			if waypoint then
				-- restore existing waypoint
				C_Map.SetUserWaypoint(waypoint)
			end
		end
	end
end)

hooksecurefunc('SubstituteChatMessageBeforeSend', function()
	if origEditbox then
		-- restore original message in editbox after sending
		origEditbox:SetText(origMessage)
		origEditbox = nil
		origMessage = nil
	end
end)
