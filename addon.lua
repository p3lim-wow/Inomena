local addonName, addon = ...

-- objects
addon.mixins = {}

-- constants
addon.NAME = addonName
addon.FONT = addonName .. 'FontNormal'
addon.TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
addon.CLASS = UnitClassBase('player')
