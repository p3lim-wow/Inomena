local E, F, C = unpack(select(2, ...))

local function OnUpdate(self, elapsed)
	if(self.expiration) then
		self.expiration = math.max(self.expiration - elapsed, 0)

		if(self.expiration <= 0 or self.expiration > 90) then
			self:SetText()
		else
			self:SetText(math.floor(self.expiration))
		end
	end
end

local function OnAttributeChanged(self, attribute, value)
	if(attribute ~= 'index') then
		return
	end

	local name, _, texture, count, _, _, expiration = UnitAura(self:GetParent():GetAttribute('unit'), value, 'HELPFUL')
	if(name) then
		self:SetNormalTexture(texture)
		self.Count:SetText(count > 1 and count or '')
		self.expiration = expiration - GetTime()
	end
end

local Header = CreateFrame('Frame', C.Name .. 'AuraHeader', UIParent, 'SecureAuraHeaderTemplate')
Header:SetAttribute('template', 'InomenaAuraTemplate')
Header:SetAttribute('unit', 'player')
Header:SetAttribute('filter', 'HELPFUL')
Header:SetPoint('TOPRIGHT', Minimap, 'TOPLEFT', -20, 0)

Header:SetAttribute('sortMethod', 'TIME')
Header:SetAttribute('sortDirection', '+')
Header:SetAttribute('point', 'TOPRIGHT')
Header:SetAttribute('minWidth', 330)
Header:SetAttribute('minHeight', 99)
Header:SetAttribute('xOffset', -33)
Header:SetAttribute('wrapYOffset', -33)
Header:SetAttribute('wrapAfter', 15)

Header:HookScript('OnAttributeChanged', function(self, name, Button)
	if(not string.match(name, '^child')) then
		return
	end

	Button:SetBackdrop(C.PlainBackdrop)
	Button:SetBackdropColor(0, 0, 0)
	Button:SetScript('OnUpdate', OnUpdate)
	Button:SetScript('OnAttributeChanged', OnAttributeChanged)

	local Texture = Button:CreateTexture('$parentTexture', 'BORDER')
	Texture:SetAllPoints()
	Texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	Button:SetNormalTexture(Texture)

	local Duration = Button:CreateFontString('$parentDuration', nil, 'PixelFontNormal')
	Duration:SetPoint('TOPLEFT', 1, -1)
	Button:SetFontString(Duration)

	local Count = Button:CreateFontString('$parentCount', nil, 'PixelFontNormal')
	Count:SetPoint('BOTTOMRIGHT', -1, 1)
	Button.Count = Count
end)

Header:Show()

RegisterAttributeDriver(Header, 'unit', '[vehicleui] vehicle; player')

TemporaryEnchantFrame:UnregisterAllEvents()
TemporaryEnchantFrame:Hide()

BuffFrame:UnregisterAllEvents()
BuffFrame:Hide()
