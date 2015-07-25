local E, F, C = unpack(select(2, ...))

C.PlainTexture = [[Interface\ChatFrame\ChatFrameBackground]]
C.PlainBackdrop = {
	bgFile = C.PlainTexture,
	insets = {top = -1, bottom = -1, left = -1, right = -1}
}
