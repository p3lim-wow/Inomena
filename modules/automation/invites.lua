local E, F = unpack(select(2, ...))

function E:PARTY_INVITE_REQUEST(name, l, f, g)
	if(QueueStatusMinimapButton:IsShown()) then return end
	if(l or f or g) then return end

	for index = 1, select(2, GetNumGuildMembers()) do
		local characterName = GetGuildRosterInfo(index)
		if(characterName and string.split('-', characterName) == name) then
			return AcceptGroup()
		end
	end

	for index = 1, select(2, BNGetNumFriends()) do
		local friend = C_BattleNet.GetFriendAccountInfo(index)
		if(friend.gameAccountInfo.clientProgram == BNET_CLIENT_WOW and friend.gameAccountInfo.characterName:match(name)) then
			return AcceptGroup()
		end
	end

	for index = 1, C_FriendList.GetNumFriends() do
		local friend = C_FriendList.GetFriendInfoByIndex(index)
		if(friend and friend.name == name) then
			return AcceptGroup()
		end
	end
end

function E:PARTY_LEADER_CHANGED()
	if(StaticPopup_Visible('PARTY_INVITE')) then
		StaticPopup_Hide('PARTY_INVITE')
	elseif(StaticPopup_Visible('PARTY_INVITE_XREALM')) then
		StaticPopup_Hide('PARTY_INVITE_XREALM')
	end
end
