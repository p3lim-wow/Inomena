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
