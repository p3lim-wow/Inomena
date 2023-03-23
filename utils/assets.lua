local _, addon = ...

addon.TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]

-- modified version of AvantGarde to include cyrillic characters, by muleyo @ wowui discord
addon.FONT = [[Interface\AddOns\Inomena\assets\AvantGarde.ttf]]

-- register our font with LibSharedMedia
local LSM = LibStub and LibStub('LibSharedMedia-3.0', true)
if LSM then
	LSM:Register('font', 'Avant Garde', addon.FONT)
end
