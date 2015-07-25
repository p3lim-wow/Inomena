local E, F = unpack(select(2, ...))

function E:PARTY_INVITE_REQUEST(name, l, f, g)
	if(QueueStatusMinimapButton:IsShown()) then return end
	if(l or f or g) then return end

	for index = 1, select(2, GetNumGuildMembers()) do
		if(string.split('-', (GetGuildRosterInfo(index))) == name) then
			return AcceptGroup()
		end
	end

	for index = 1, select(2, BNGetNumFriends()) do
		if(string.match(select(5, BNGetFriendInfo(index)), name)) then
			return AcceptGroup()
		end
	end

	for index = 1, GetNumFriends() do
		if(GetFriendInfo(index) == name) then
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
