local E, F, C = unpack(select(2, ...))

function ChatEdit_UpdateHeader(self)
	local chatType = self:GetAttribute('chatType')
	if(not chatType) then
		return
	end

	local info = ChatTypeInfo[chatType]
	local header = self.header
	if(not header) then
		return
	end

	local target = self:GetAttribute('tellTarget')
	if(chatType == 'SMART_WHISPER') then
		if(GetAutoCompletePresenceID(target)) then
			self:SetAttribute('chatType', 'BN_WHISPER')
		else
			self:SetAttribute('chatType', 'WHISPER')
		end

		return ChatEdit_UpdateHeader(self)
	elseif(chatType == 'WHISPER') then
		-- TODO: class color
		header:SetFormattedText('|cffa1a1a1@|r%s: ', target)
	elseif(chatType == 'BN_WHISPER') then
		local _, _, battleTag, _, _, _, client = BNGetFriendInfoByID(GetAutoCompletePresenceID(target))
		local color = C.ClientColors[client] or '22aaff'
		header:SetFormattedText('|cffa1a1a1@|r|cff%s%s|r: ', color, string.match(battleTag, '(%w+)#%d+'))
	elseif(chatType == 'EMOTE') then
		header:SetFormattedText(CHAT_EMOTE_SEND, YOU)
	elseif(chatType == 'CHANNEL') then
		local channel, channelName, instanceID = GetChannelName(self:GetAttribute('channelTarget'))
		if(channelName) then
			channelName = string.match(channelName, '%w+')

			if(instanceID > 0) then
				channelName = channelName .. instanceID
			end

			info = ChatTypeInfo['CHANNEL' .. channel]
			self:SetAttribute('channelTarget', channel)
			header:SetFormattedText('%s: ', channelName)
		end
	elseif(chatType == 'PARTY' and (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE))) then
		self:SetAttribute('chatType', 'INSTANCE_CHAT')
		return ChatEdit_UpdateHeader(self)
	elseif(chatType == 'RAID' and (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE))) then
		self:SetAttribute('chatType', 'INSTANCE_CHAT')
		return ChatEdit_UpdateHeader(self)
	elseif(chatType == 'INSTANCE_CHAT' and (IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE))) then
		if(IsInRaid(LE_PARTY_CATEGORY_HOME)) then
			self:SetAttribute('chatType', 'RAID')
		else
			self:SetAttribute('chatType', 'PARTY')
		end

		return ChatEdit_UpdateHeader(self)
	else
		header:SetText(_G['CHAT_' .. chatType .. '_SEND'])
	end

	local headerSuffix = self.headerSuffix
	local headerWidth = (header:GetRight() or 0) - (header:GetLeft() or 0)
	local width = self:GetRight() - self:GetLeft()
	if(headerWidth > width / 2) then
		header:SetWidth(width / 2)
		headerSuffix:Show()
	else
		headerSuffix:Hide()
	end

	header:SetTextColor(info.r, info.g, info.b)
	headerSuffix:SetTextColor(info.r, info.g, info.b)
	self:SetTextColor(info.r, info.g, info.b)
	self:SetTextInsets(header:GetWidth(), 0, 0, 0)
end
