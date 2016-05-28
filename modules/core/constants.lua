local E, F, C = unpack(select(2, ...))

C.PlainTexture = [[Interface\ChatFrame\ChatFrameBackground]]
C.PlainBackdrop = {
	bgFile = C.PlainTexture,
	insets = {top = -1, bottom = -1, left = -1, right = -1}
}

C.EdgeBackdrop = {
	edgeFile = C.PlainTexture, edgeSize = 1,
	insets = {top = 1, bottom = 1, left = 1, right = 1},
}

C.Font = [[Interface\AddOns\Inomena\assets\semplice.ttf]]

C.isBetaClient = select(4, GetBuildInfo()) >= 70000

C.ClientColors = {
	[BNET_CLIENT_WOW] = '5cc400',
	[BNET_CLIENT_D3] = 'b71709',
	[BNET_CLIENT_SC2] = '00b6ff',
	[BNET_CLIENT_WTCG] = 'd37000',
	[BNET_CLIENT_HEROES] = '6800c4',
	[BNET_CLIENT_OVERWATCH] = 'dcdcef',
}
