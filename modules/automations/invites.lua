local _, addon = ...

-- accept invites from friends

local function IsFriend(guid)
	-- update friend list
	C_FriendList.ShowFriends()

	-- check friends
	for index = 1, C_FriendList.GetNumFriends() do
		local friendInfo = C_FriendList.GetFriendInfoByIndex(index)
		if friendInfo and friendInfo.guid == guid then
			return true
		end
	end

	-- check bnet friends
	if C_BattleNet.GetAccountInfoByGUID(guid) then
		return true
	end

	-- check guild members
	for index = 1, (GetNumGuildMembers()) do
		local _, _, _, _, _, _, _, _, isOnline, _, _, _, _, _, _, _, memberGUID = GetGuildRosterInfo(index)
		if isOnline and memberGUID == guid then
			return true
		end
	end
end

local function HidePopup()
	if StaticPopup_Visible('PARTY_INVITE') then
		StaticPopup_Hide('PARTY_INVITE')
	elseif StaticPopup_Visible('PARTY_INVITE_XREALM') then
		StaticPopup_Hide('PARTY_INVITE_XREALM')
	elseif StaticPopup_Visible('GROUP_INVITE_CONFIRMATION') then
		StaticPopup_Hide('GROUP_INVITE_CONFIRMATION')
	end

	return true
end

function addon:PARTY_INVITE_REQUEST(_, isTank, isHealer, isDamager, _, _, inviterGUID)
	if QueueStatusButton:IsVisible() then
		-- don't lose queue
		return
	end

	if isTank or isHealer or isDamager then
		-- don't accept if prompted for a role
		return
	end

	if IsFriend(inviterGUID) then
		HidePopup()
		AcceptGroup()
	end
end

function addon:GROUP_INVITE_CONFIRMATION()
	if QueueStatusButton:IsVisible() then
		-- don't lose queue
		return
	end

	local requesterGUID = GetNextPendingInviteConfirmation()
	if requesterGUID and IsFriend(requesterGUID) then
		HidePopup()
		RespondToInviteConfirmation(requesterGUID, true)
	end
end

-- auto-confirm role checks
LFDRoleCheckPopupAcceptButton:HookScript('OnShow', function(self)
	if IsShiftKeyDown() then
		return
	end

	for index = 1, GetNumGroupMembers() do
		if UnitIsGroupLeader('party' .. index) then
			if IsFriend(UnitGUID('party' .. index)) then
				self:Click()
			end

			break
		end
	end
end)
