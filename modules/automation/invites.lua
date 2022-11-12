local _, addon = ...

local function isPlayerKnown(playerName)
	-- is it a guildie?
	for index = 1, select(2, GetNumGuildMembers()) do
		local characterName = GetGuildRosterInfo(index)
		if characterName == playerName then
			return true
		end
	end

	-- is it a battlenet friend?
	for index = 1, select(2, BNGetNumFriends()) do
		local friend = C_BattleNet.GetFriendAccountInfo(index).gameAccountInfo
		if friend.clientProgram == BNET_CLIENT_WOW and friend.realmName then
			-- character names do not contain realm
			local characterName = friend.characterName .. '-' .. friend.realmName
			if characterName == playerName then
				return true
			end
		end
	end

	-- friends are always on the same realm, and as such contains no realm in the name
	local localName = string.split('-', playerName)

	-- is it a friend?
	for index = 1, C_FriendList.GetNumFriends() do
		local friend = C_FriendList.GetFriendInfoByIndex(index)
		if friend and friend.name == localName then
			return true
		end
	end
end

-- invite known player when asked
function addon:CHAT_MSG_WHISPER(msg, playerName)
	msg = msg:lower():trim()

	if msg == 'inv'  or msg == 'invite' then
		if isPlayerKnown(playerName) then
			C_PartyInfo.InviteUnit(playerName)
		end
	end
end

-- accept invite from known player
function addon:PARTY_INVITE_REQUEST(playerName, l, f, g)
	if QueueStatusButton:IsVisible() then
		-- don't accept if in a queue
		return
	end

	if l or f or g then
		-- don't accept if prompted for a role
		return
	end

	if not playerName:find('-') then
		-- for consistency, native realm invite requests don't contain the realm name
		playerName = playerName .. '-' .. GetRealmName()
	end

	if isPlayerKnown(playerName) then
		AcceptGroup()
	end
end

-- accept invite request from known player
function addon:REQUEST_INVITE_CONFIRMATION(playerName, _, l, f, g)
	if not playerName:find('-') then
		-- for consistency, native realm invite requests don't contain the realm name
		playerName = playerName .. '-' .. GetRealmName()
	end

	if isPlayerKnown(playerName) then
		C_PartyInfo.ConfirmRequestInviteFromUnit(playerName, l, f, g)
	end
end

-- accept invite requests from known bnet player
function addon:BNET_REQUEST_INVITE_CONFIRMATION(gameAccountID, _, l, f, g)
	-- if it's a bnet invite we must already know the player
	ConfirmBNRequestInviteFriend(gameAccountID, l, f, g)
end

-- whenever we accept an invite we need to hide the popups
function addon:PARTY_LEADER_CHANGED()
	if StaticPopup_Visible('PARTY_INVITE') then
		StaticPopup_Hide('PARTY_INVITE')
	elseif StaticPopup_Visible('PARTY_INVITE_XREALM') then
		StaticPopup_Hide('PARTY_INVITE_XREALM')
	end
end
