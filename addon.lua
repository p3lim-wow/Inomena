local addonName, addon = ...

-- objects
addon.mixins = {}

-- constants
addon.NAME = addonName
addon.FONT = 'PixelFontNormal' -- TODO: remove dependency
addon.TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
addon.CLASS = UnitClassBase('player')
