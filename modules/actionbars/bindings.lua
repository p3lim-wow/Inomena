local E, F, C = unpack(select(2, ...))

local gsub = string.gsub
local function CleanKey(key)
	if(key) then
		key = string.upper(key)
		key = gsub(key, ' ', '')
		key = gsub(key, '%-', '')
		key = gsub(key, 'MOUSEBUTTON', 'B')
		key = gsub(key, 'MIDDLEMOUSE', 'MM')
		key = gsub(key, 'BACKSPACE', 'BS')

		return key
	end
end

local actionButtons = C.actionButtons
local function UpdateBindings()
	for _, name in next, actionButtons do
		for index = 1, NUM_ACTIONBAR_BUTTONS do
			local Button = _G[name .. index]
			if(Button) then
				local HotKey = Button.HotKey
				if(HotKey) then
					HotKey:SetText(CleanKey(HotKey:GetText()) or '')
				end
			end
		end
	end
end

E.PLAYER_LOGIN = UpdateBindings
E.UPDATE_BINDINGS = UpdateBindings
