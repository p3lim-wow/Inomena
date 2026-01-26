local _, addon = ...

-- disable skyriding action bar

-- we bind the spells directly (modules/settings/bindings/skyriding.lua), and we display
-- cooldowns in a separate widget (modules/widgets/skyriding.lua)

local listener = CreateFrame('Frame', nil, nil, 'SecureHandlerStateTemplate')

-- add references for bars/buttons we manipulate
listener:SetFrameRef('ActionBar', MainActionBar)
listener:SetAttribute('numButtons', NUM_ACTIONBAR_BUTTONS)

for index = 1, NUM_ACTIONBAR_BUTTONS do
	listener:SetFrameRef('ActionButton' .. index, _G['ActionButton' .. index])
end

-- create a table of buttons on init for easier referencing later
listener:Execute([[
	buttons = table.new()
	for index = 1, self:GetAttribute('numButtons') do
		buttons[index] = self:GetFrameRef('ActionButton' .. index)
	end
]])

-- store the last page so we know what to revert back to
listener:SetAttribute('_onstate-page', [[
	self:SetAttribute('page', newstate ~= 'ignore' and newstate or nil)
]])

-- update page attributes for bars and buttons on skyriding state change
listener:SetAttribute('_onstate-skyriding', [[
	local page = self:GetAttribute('page')
	if newstate == 'mounted' and page then
		-- player has mounted, set the last known page
		self:GetFrameRef('ActionBar'):SetAttribute('actionpage', page)

		-- repeat for each button to force their state
		for _, button in pairs(buttons) do
			button:SetAttribute('actionpage', page)
		end
	elseif newstae == 'reset' then
		-- this is the normal state (dismounted), make sure we don't force the buttons
		for _, button in pairs(buttons) do
			button:SetAttribute('actionpage', nil)
		end
	end
]])

-- default pages for all classes
local PAGES = '[overridebar][possessbar][shapeshift] ignore; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6'

-- append extra pages (bonusbar) for classes with forms
if addon.PLAYER_CLASS == 'DRUID' then
	PAGES = PAGES .. '; [form:1] 9; [form:2] 7; [known:197625,form:4] 10' -- bear, cat, moonkin
elseif addon.PLAYER_CLASS == 'ROGUE' then
	PAGES = PAGES .. '; [form:1] 7' -- stealth
end

-- append default page
PAGES = PAGES .. '; 1'

-- register state drivers
RegisterStateDriver(listener, 'page', PAGES)
RegisterStateDriver(listener, 'skyriding', '[bonusbar:5] mounted; reset')
