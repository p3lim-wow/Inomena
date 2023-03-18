local _, addon = ...

local SLASH_SMART_WHISPER1 = _G.SLASH_SMART_WHISPER1 -- globalstring

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
		if C_QuestLog.IsQuestFlaggedCompleted(questID) then
			addon:Printf('Quest %s is |cff00ff00COMPLETE|r', questID)
		else
			addon:Printf('Quest %s is |cffff0000NOT complete|r', questID)
		end
	end
end)

addon:RegisterSlash('/mapid', function()
	local mapID
	if WorldMapFrame:IsShown() then
		mapID = WorldMapFrame:GetMapID()
	else
		mapID = addon:GetPlayerMapID()
	end

	print('Map ID:', mapID, 'for', C_Map.GetMapInfo(mapID).name)
end)

addon:RegisterSlash('/npcid', function()
	local npcID = addon:GetNPCID('target')
	if npcID then
		print('NPC ID:', npcID)
	end
end)

addon:RegisterSlash('/dumpui', SlashCmdList.TABLEINSPECT)
