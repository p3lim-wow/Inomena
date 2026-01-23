local addonName, addon = ...

addon.PATH = ([[Interface\AddOns\%s\assets\]]):format(addonName)
addon.TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
addon.GLOW = { -- backdrop
	edgeFile = addon.PATH .. 'glow', edgeSize = 4
}

-- modified version of AvantGarde to include cyrillic characters, by muleyo @ wowui discord
addon.FONT = addon.PATH .. 'AvantGarde.ttf'

-- register our font with LibSharedMedia
local LSM = LibStub and LibStub('LibSharedMedia-3.0', true)
if LSM then
	LSM:Register('font', 'Avant Garde', addon.FONT)
end
