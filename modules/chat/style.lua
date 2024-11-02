local _, addon = ...

-- prevent stickyness
ChatTypeInfo.CHANNEL.sticky = 0
ChatTypeInfo.WHISPER.sticky = 0
ChatTypeInfo.BN_WHISPER.sticky = 0

-- make more channels flash
ChatTypeInfo.GUILD.flashTab = true
ChatTypeInfo.OFFICER.flashTab = true

-- change font
for index = 1, NUM_CHAT_WINDOWS do
	_G['ChatFrame' .. index]:SetFont(addon.FONT, 13, 'OUTLINE')
	_G['ChatFrame' .. index]:SetShadowOffset(0, 0)
	_G['ChatFrame' .. index .. 'Tab'].Text:SetFont(addon.FONT, 12, 'OUTLINE')
	_G['ChatFrame' .. index .. 'Tab'].Text:SetShadowOffset(0, 0)
end

ChatFrame1EditBox:SetFont(addon.FONT, 13, 'OUTLINE')
ChatFrame1EditBox:SetShadowOffset(0, 0)
ChatFrame1EditBoxHeader:SetFont(addon.FONT, 13, 'OUTLINE')
ChatFrame1EditBoxHeader:SetShadowOffset(0, 0)

-- remove textures
for index = 1, NUM_CHAT_WINDOWS do
	for _, region in next, {_G['ChatFrame' .. index]:GetRegions()} do
		addon:Hide(region)
	end
end

-- group colors
ChangeChatColor('OFFICER', 3/4, 1/2, 1/2)
ChangeChatColor('RAID', 0, 1, 4/5)
ChangeChatColor('RAID_LEADER', 0, 1, 4/5)
ChangeChatColor('RAID_WARNING', 1, 1/4, 1/4)
ChangeChatColor('BATTLEGROUND_LEADER', 1, 1/2, 0)
ChangeChatColor('PARTY_LEADER', 2/3, 2/3, 1)
ChangeChatColor('BN_WHISPER', 1, 1/2, 1)
ChangeChatColor('BN_WHISPER_INFORM', 1, 1/2, 1)
ChangeChatColor('INSTANCE_CHAT_LEADER', 1, 1/2, 0)

-- force enable class colors in chat
function addon:UPDATE_CHAT_COLOR_NAME_BY_CLASS(chatType, shouldColor)
	if not shouldColor then
		SetChatColorNameByClass(chatType, true)
	end
end
