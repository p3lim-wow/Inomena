local _, addon = ...

-- bind D.R.I.V.E boost to an extra key to match my binds for skyriding

local BOOST_KEY = 'BUTTON4'
local DRIVE_CONDITION = '[overridebar,mounted] mounted; reset'
local DRIVE_MAPS = {
	[2346] = true, -- Undermine
	[2406] = true, -- Undermine (raid)
}

local button = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate')
button:SetAttribute('_onstate-drive', ([[
	if newstate == 'mounted' then
		self:SetBindingClick(true, '%s', 'OverrideActionBarButton1')
	elseif newstate == 'reset' then
		self:ClearBindings()
	end
]]):format(BOOST_KEY))

local function updateState()
	if DRIVE_MAPS[addon:GetPlayerMapID()] then
		addon:Defer('RegisterStateDriver', button, 'drive', DRIVE_CONDITION)
	else
		addon:Defer('UnregisterStateDriver', button, 'drive')
	end
end

addon:RegisterEvent('ZONE_CHANGED', updateState)
addon:RegisterEvent('PLAYER_LOGIN', updateState)
addon:RegisterEvent('PLAYER_ENTERING_WORLD', updateState)
