local E, F, C = unpack(select(2, ...))

if(C.isBetaClient) then
	return
end

local buttons = {}
local buffs = {
	{'spell_nature_regeneration', {[2] = 20217, [3] = 160206, [10] = {116781, 115921}, [11] = 1126}},
	{'spell_holy_wordfortitude', {[3] = 160199, [5] = 21562, [9] = 166928}},
	{'ability_warrior_battleshout', {[1] = 6673, [6] = 57330}},
	{'inv_helmet_08', {[3] = 160203}},
	{'spell_holy_magicalsentry', {[3] = 160205, [8] = {61316, 1459}, [9] = 109773}},
	{'spell_nature_unyeildingstamina', {[3] = 160200, [8] = {61316, 1459}, [10] = 116781}},
	{'spell_holy_greaterblessingofkings', {[2] = 19740, [3] = 160198}},
	{'inv_elemental_mote_air01', {[3] = 172968, [9] = 109773}},
	{'spell_holy_mindvision', {[3] = 172967, [11] = 1126}},
}

local ScanTooltip = CreateFrame('GameTooltip', 'ScanTooltip' .. GetTime(), nil, 'GameTooltipTemplate')
ScanTooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')

local tooltipName = ScanTooltip:GetName()

local function GetCaster(buffID)
	for index = 1, 40 do
		local _, _, _, _, _, _, _, caster, _, _, spellID = UnitBuff('player', index)
		if(spellID == buffID) then
			if(caster) then
				if(UnitIsPlayer(caster)) then
					return caster
				else
					ScanTooltip:ClearLines()
					ScanTooltip:SetUnit(caster)

					local line = _G[tooltipName .. 'TextLeft2']:GetText()
					if(line) then
						local owner = string.split('\'', line)
						if(owner and UnitIsPlayer(owner)) then
							return owner
						end
					end
				end
			end
		end
	end
end

local STRING_CASTER = string.format('%s: |c%%s%%s|r', string.gsub(SPELL_TARGET_CENTER_CASTER, '^%l', string.upper))
local function OnButtonEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
	GameTooltip:AddLine(self.name, 1, 1, 1)

	if(self.spellID) then
		local caster = GetCaster(self.spellID)
		if(caster) then
			local _, className = UnitClass(caster)
			local colorStr = RAID_CLASS_COLORS[className].colorStr

			GameTooltip:AddLine(string.format(STRING_CASTER, colorStr, GetUnitName(caster, false)))
		end
	end

	GameTooltip:Show()

	self:GetParent():SetAlpha(1)
end

local function OnButtonLeave(self)
	GameTooltip:Hide()

	if(not self:GetParent():IsMouseOver()) then
		self:GetParent():SetAlpha(0)
	end
end

local function OnParentEnter(self)
	self:SetAlpha(1)
end

local function OnParentLeave(self)
	if(not self:IsMouseOver()) then
		self:SetAlpha(0)
	end
end

local function CreateButton(self, index, texture, spells)
	local Button = CreateFrame('Button', nil, self, 'SecureActionButtonTemplate')
	Button:SetSize(22, 22)
	Button:SetBackdrop(C.EdgeBackdrop) -- TODO: check
	Button:SetBackdropBorderColor(0, 0, 0)
	Button:SetScript('OnEnter', OnButtonEnter)
	Button:SetScript('OnLeave', OnButtonLeave)
	Button.name = _G['RAID_BUFF_' .. index]

	local Background = Button:CreateTexture(nil, 'BACKGROUND')
	Background:SetPoint('TOPRIGHT', -1, -1)
	Background:SetPoint('BOTTOMLEFT', 1, 1)
	Background:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	Background:SetTexture([[Interface\Icons\]] .. texture)
	Background:SetDesaturated(true)
	Button.Background = Background

	local Texture = Button:CreateTexture(nil, 'BORDER')
	Texture:SetAllPoints(Background)
	Texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	Button:SetNormalTexture(Texture)

	if(index == 1) then
		Button:SetPoint('TOPRIGHT', -8, -20)
	elseif(index == 6) then
		Button:SetPoint('TOPRIGHT', buttons[1], 'TOPLEFT', -4, 0)
	else
		Button:SetPoint('TOPLEFT', buttons[index - 1], 'BOTTOMLEFT', 0, -4)
	end

	if(spells) then
		if(type(spells) == 'table') then
			for _, spell in next, spells do
				if(IsSpellKnown(spell)) then
					spells = spell
					break
				end
			end
		end

		Button:SetAttribute('type1', 'spell')
		Button:SetAttribute('spell', spells)
		Button:SetBackdropBorderColor(0, 1, 1)
	end

	buttons[index] = Button
end

local function UpdateTray()
	local mask = 1
	local buffMask = GetRaidBuffInfo()

	for index, Button in next, buttons do
		local _, _, texture, _, _, spellID = GetRaidBuffTrayAuraInfo(index)
		Button.spellID = spellID

		if(texture) then
			Button:SetNormalTexture(texture)
			Button:SetAlpha(1)
		else
			Button:SetNormalTexture('')
			Button:SetAlpha(0.2)

			if(bit.band(buffMask, mask) > 0) then
				Button.Background:SetVertexColor(1, 0, 0)
			else
				Button.Background:SetVertexColor(1, 1, 1)
			end
		end

		if(Button:IsMouseOver()) then
			OnButtonEnter(Button)
		end

		mask = bit.lshift(mask, 1)
	end
end

E.PLAYER_ENTERING_WORLD = UpdateTray
E.GROUP_ROSTER_UPDATE = UpdateTray
E.PLAYER_SPECIALIZATION_CHANGED = UpdateTray

function E:UNIT_AURA(unit)
	if(unit == 'player' or unit == 'vehicle') then
		UpdateTray()
	end
end

function E:PLAYER_LOGIN()
	local Parent = CreateFrame('Frame', nil, UIParent)
	Parent:SetPoint('TOPRIGHT', Minimap, 'TOPLEFT', 0, 20)
	Parent:SetSize(100, 160)
	Parent:SetAlpha(0)
	Parent:SetScript('OnEnter', OnParentEnter)
	Parent:SetScript('OnLeave', OnParentLeave)

	local playerClass = select(3, UnitClass('player'))
	for index, data in next, buffs do
		CreateButton(Parent, index, data[1], data[2][playerClass])
	end
end
