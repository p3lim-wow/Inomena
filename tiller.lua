local Handler = CreateFrame('Frame')
Handler:RegisterEvent('ZONE_CHANGED')
Handler:RegisterEvent('PLAYER_LOGIN')

local Seed = CreateFrame('Button', 'SeedButton', nil, 'SecureActionButtonTemplate')
Seed:SetAttribute('type', 'item')
Seed:SetAttribute('item', 'item:89233')

local Plow = CreateFrame('Button', 'PlowButton', nil, 'SecureActionButtonTemplate')
Plow:SetAttribute('type', 'item')
Plow:SetAttribute('item', 'item:89815')

local DoubleClick
do
	local last
	function DoubleClick()
		if(last) then
			local press = GetTime() - last
			if(press < 0.5 and press > 0.05) then
				last = nil
				return true
			end
		end
		
		last = GetTime()
		return false
	end
end

local function Override(button)
	if(IsMouselooking()) then
		MouselookStop()
	end

	Handler:RegisterEvent('UNIT_SPELLCAST_SENT')
	Handler:RegisterEvent('UI_ERROR_MESSAGE')

	SetOverrideBindingClick(Handler, false, 'BUTTON1', button)
end

local disabled = true

WorldFrame:HookScript('OnMouseDown', function(self, button)
	if(disabled or InCombatLockdown() or not DoubleClick() or button ~= 'LeftButton') then return end

	local id = tonumber(string.sub(UnitGUID('target') or '', -12, -9), 16) or 0
	if(id == 58563 and GetItemCount(89233) > 0) then
		Override('SeedButton')
	elseif(id == 58562 and GetItemCount(89815) > 0) then
		Override('PlowButton')
	end
end)

Handler:SetScript('OnEvent', function(self, event)
	if(event == 'ZONE_CHANGED' or event == 'PLAYER_LOGIN') then
		if(GetSubZoneText() == 'Sunsong Ranch') then
			disabled = false
		else
			disabled = true
		end
	elseif(event == 'UNIT_SPELLCAST_SENT' or event == 'UI_ERROR_MESSAGE') then
		ClearOverrideBindings(self)

		self:UnregisterEvent('UNIT_SPELLCAST_SENT')
		self:UnregisterEvent('UI_ERROR_MESSAGE')
	end
end)
