
local _, Inomena = ...

local dialogShown
local infoString = string.format('%s from |cff0090ff%%s|r.', string.sub(BN_INLINE_TOAST_FRIEND_REQUEST, 0, -2))

local function Request()
	local numPending = BNGetNumFriendInvites()
	if(numPending > 0 and not dialogShown) then
		local _, _, _, _, _, _, enabled = BNGetInfo()
		if(enabled) then
			local inviteID, presenceName, isTag = BNGetFriendInviteInfo(numPending)

			if(isTag) then
				presenceName = '#' .. presenceName
			end

			local dialog = StaticPopup_Show('BNET_INVITE_REQUEST', string.format(infoString, presenceName))
			dialog.inviteID = inviteID

			dialogShown = true
		end
	end
end

local function AcceptRequest(dialog)
	BNAcceptFriendInvite(dialog.inviteID)
	Request()
end

local function DeclineRequest(dialog)
	BNDeclineFriendInvite(dialog.inviteID)
	Request()
end

local function OnHide()
	dialogShown = false
end

StaticPopupDialogs.BNET_INVITE_REQUEST = {
	text = '%s',
	button1 = ACCEPT,
	button2 = IGNORE,
	button3 = DECLINE,
	OnAccept = AcceptRequest,
	OnAlt = DeclineRequest,
	OnHide = OnHide,
	timeout = 0,
}

Inomena.RegisterEvent('BN_FRIEND_INVITE_ADDED', Request)
Inomena.RegisterEvent('BN_FRIEND_INVITE_LIST_INITIALIZED', Request)
