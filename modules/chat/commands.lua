local _, addon = ...

hooksecurefunc('ChatEdit_OnSpacePressed', function(editBox)
	if editBox:GetText():sub(1, 3) == '/tt' and (UnitCanCooperate('player', 'target') or UnitIsUnit('player', 'target')) then
		editBox:SetText(SLASH_SMART_WHISPER1 .. ' ' .. GetUnitName('target', true):gsub(' ', '') .. ' ')
		ChatEdit_ParseText(editBox, 0)
	end
end)

addon:RegisterSlash('/tt', function(msg)
	if UnitCanCooperate('player', 'target') or UnitIsUnit('player', 'target') then
		SendChatMessage(msg, 'WHISPER', nil, GetUnitName('target', true))
	end
end)

addon:RegisterSlash('/complete', function(msg)
	local questID = tonumber(msg)
	if questID then
		print('Quest', questID, 'is', C_QuestLog.IsQuestFlaggedCompleted(questID) and 'COMPLETE' or 'NOT complete')
	end
end)

addon:RegisterSlash('/mapid', function()
	local mapID
	if WorldMapFrame:IsShown() then
		mapID = WorldMapFrame:GetMapID()
	else
		mapID = C_Map.GetBestMapForUnit('player')
	end

	print('Map ID:', mapID, 'for', C_Map.GetMapInfo(mapID).name)
end)

addon:RegisterSlash('/npcid', function()
	local npcID = addon:GetNPCID('target')
	if npcID then
		print('NPC ID:', npcID)
	end
end)
