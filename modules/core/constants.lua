local E, F, C = unpack(select(2, ...))

C.Name = ...

C.PlainTexture = [[Interface\ChatFrame\ChatFrameBackground]]
C.PlainBackdrop = {
	bgFile = C.PlainTexture,
	insets = {top = -1, bottom = -1, left = -1, right = -1}
}

C.InsetBackdrop = {
	bgFile = C.PlainTexture,
	insets = {top = 1, bottom = 1, left = 1, right = 1}
}

C.EdgeBackdrop = {
	edgeFile = C.PlainTexture, edgeSize = 1,
	insets = {top = 1, bottom = 1, left = 1, right = 1},
}

C.Font = [[Interface\AddOns\Inomena\assets\semplice.ttf]]
C.FontSize = 8
C.FontFlags = 'OUTLINEMONOCHROME'

C.ClientColors = {
	[BNET_CLIENT_WOW] = '5cc400',
	[BNET_CLIENT_D3] = 'b71709',
	[BNET_CLIENT_SC2] = '00b6ff',
	[BNET_CLIENT_WTCG] = 'd37000',
	[BNET_CLIENT_HEROES] = '6800c4',
	[BNET_CLIENT_OVERWATCH] = 'dcdcef',
}

C.playerClass = select(2, UnitClass('player'))

-- Colors
C.BLACK = CreateColor(0, 0, 0)
C.YELLOW = YELLOW_FONT_COLOR
C.BLUE = LIGHTBLUE_FONT_COLOR

-- Temp
C.BfA = select(4, GetBuildInfo()) >= 80000

-- Expose (mainly for Inomena_Settings)
_G[C.Name] = {E, F, C}

local LSM = LibStub('LibSharedMedia-3.0', true)
if(LSM) then
	LSM:Register(LSM.MediaType.STATUSBAR, 'ChatFrameBackground', C.PlainTexture)
end
