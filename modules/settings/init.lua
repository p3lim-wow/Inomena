local E, F, C = unpack(select(2, ...))

C.Settings = {}
local function Initialize()
	for _, update in next, C.Settings do
		update()
	end

	F:Print('Successfully initialized settings')
	InomenaSettings = true
end

local function Decline()
	F:Print('Settings not initialized, you can do so later with /init')
	InomenaSettings = true
end

StaticPopupDialogs.INOMENA_INITIALIZE = {
	text = '|cffff6000Inomena:|r Load settings?',
	button1 = YES,
	button2 = NO,
	OnAccept = Initialize,
	OnCancel = Decline,
	timeout = 0
}

function E:PLAYER_LOGIN()
	if(not InomenaSettings) then
		StaticPopup_Show('INOMENA_INITIALIZE')
	end
end

F:RegisterSlash('/init', Initialize)

_G.XX = C.Settings