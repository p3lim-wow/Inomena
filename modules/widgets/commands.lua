local _, addon = ...

-- add a few useful chat commands

-- check if a quest has been completed
addon:RegisterSlash('/complete', function(msg)
	local questID = tonumber(msg)
	if questID then
		if C_QuestLog.IsQuestFlaggedCompleted(questID) then
			addon:Print('Quest', questID, 'is', WrapTextInColorCode('COMPLETE', 'ff08bc06'))
		else
			addon:Print('Quest', questID, 'is', WrapTextInColorCode('NOT complete', 'ffff0000'))
		end
	end
end)

-- output current map ID
addon:RegisterSlash('/mapid', function()
	local mapID
	if WorldMapFrame:IsShown() then
		mapID = WorldMapFrame:GetMapID()
	else
		mapID = addon:GetPlayerMapID()
	end

	if mapID then
		addon:Print('Map ID:', mapID, 'for', WrapTextInColorCode(C_Map.GetMapInfo(mapID).name, 'ffffff00'))
	else
		addon:Print('No valid map ID')
	end
end)

-- output target creature ID
addon:RegisterSlash('/creatureid', '/npcid', function()
	local creatureID = UnitExists('target') and UnitCreatureID('target')
	if creatureID then
		addon:Print('Creature ID:', creatureID, 'for', WrapTextInColorCode(UnitName('target'), 'ffffff00'))
	end
end)

-- quick chat frame clear
addon:RegisterSlash('/clear', function()
	for _, chatFrame in next, CHAT_FRAMES do
		if _G[chatFrame]:IsVisible() then
			_G[chatFrame]:Clear()
			break
		end
	end
end)

-- alias for `/tinspect`
addon:RegisterSlash('/dumpui', SlashCmdList.TABLEINSPECT)

-- why is this buried so deep into the options?
addon:RegisterSlash('/cd', '/wa', function()
	if InCombatLockdown() then
		addon:Print('Can\'t open CDM in combat')
	else
		ShowUIPanel(CooldownViewerSettings)
	end
end)

-- paste stuff into chat
local paste
addon:RegisterSlash('/paste', function()
	if InCombatLockdown() then
		addon:Print('Can\'t paste in combat!')
		return
	end

	if not paste then
		paste = addon:CreateFrame('EditBox', nil, UIParent)
		paste:Hide()
		paste:AddBackdrop()
		paste:SetPoint('TOPLEFT', UIParent, 'CENTER', -300, 200)
		paste:SetPoint('BOTTOMRIGHT', UIParent, 'CENTER', 300, -200)
		paste:SetBackgroundColor(0, 0, 0, 0.8)
		paste:SetFontObject('ChatFontNormal')
		paste:SetMultiLine(true)
		paste:SetAutoFocus(false)
		paste:SetScript('OnEscapePressed', function(self)
			self:ClearFocus()
			self:Hide()
		end)
		paste:SetScript('OnEnterPressed', function(self)
			local text = self:GetText()
			if IsControlKeyDown() then
				for _, line in next, {string.split('\n', text)} do
					-- TODO: how safe is this for midnight?
					local chat = ChatFrameUtil.OpenChat()
					chat:SetText(line)
					chat:SendText(false)
					chat:Deactivate()
				end

				self:ClearFocus()
				self:Hide()
			else
				self:SetText(text .. '\n')
			end
		end)
		paste:SetScript('OnShow', function(self)
			self:SetText('')
			self:SetFocus(true)
		end)
	end

	paste:Show()
end)
