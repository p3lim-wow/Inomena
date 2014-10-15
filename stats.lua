PAPERDOLL_STATCATEGORIES = {
	GENERAL = {
		id = 1,
		stats = {
			'ITEMLEVEL',
			'MOVESPEED',
		},
	},
	MELEE = {
		id = 2,
		stats = {
			'STRENGTH',
			'AGILITY',
			'MELEE_AP',
			'ENERGY_REGEN',
			'RUNE_REGEN',
			'HASTE',
			'CRITCHANCE',
			'HITCHANCE',
			'EXPERTISE',
			'MASTERY',
		},
	},
	RANGED = {
		id = 2,
		stats = {
			'AGILITY',
			'RANGED_AP',
			'RANGED_HASTE',
			'FOCUS_REGEN',
			'CRITCHANCE',
			'RANGED_HITCHANCE',
			'MASTERY',
		},
	},
	SPELL = {
		id = 2,
		stats = {
			'SPIRIT',
			'INTELLECT',
			'SPELLDAMAGE',
			'SPELLHEALING',
			'SPELL_HASTE',
			'MANAREGEN',
			'SPELLCRIT',
			'SPELL_HITCHANCE',
			'MASTERY',
		},
	},
	DEFENSE = {
		id = 3,
		stats = {
			'STAMINA',
			'ARMOR',
			'DODGE',
			'PARRY',
			'BLOCK',
			'RESILIENCE_REDUCTION',
			'PVP_POWER',
		},
	},
}

local orig = PaperDoll_InitStatCategories
local class = select(3, UnitClass('player'))

local sort = {
	{
		'GENERAL',
		'MELEE',
		'DEFENSE',
	},
	{
		'GENERAL',
		'RANGED',
		'DEFENSE',
	},
	{
		'GENERAL',
		'SPELL',
		'DEFENSE',
	},
}

local spec
local specs = {
	{1, 1, 1},
	{3, 1, 1},
	{2, 2, 2},
	{1, 1, 1},
	{3, 3, 3},
	{1, 1, 1},
	{3, 1, 3},
	{3, 3, 3},
	{3, 3, 3},
	{1, 3, 1},
	{3, 1, 1, 3},
}

local handler = CreateFrame('Frame')
handler:RegisterEvent('PLAYER_TALENT_UPDATE')
handler:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
handler:SetScript('OnEvent', function()
	spec = GetSpecialization()

	if(spec) then
		PaperDoll_InitStatCategories = function()
			orig(sort[specs[class][spec]], nil, nil, 'player')
			PaperDollFrame_CollapseStatCategory(CharacterStatsPaneCategory4)
		end
	end
end)

for index = 1, 3 do
	local toolbar = _G['CharacterStatsPaneCategory' .. index .. 'Toolbar']
	toolbar:SetScript('OnEnter', nil)
	toolbar:SetScript('OnClick', nil)
	toolbar:RegisterForDrag()
end

do
	local setStat = PaperDollFrame_SetStat
	function PaperDollFrame_SetStat(self, ...)
		if(index == 1 and class ~= 6 and class ~= 2 and class ~= 1) then
			return self:Hide()
		end

		setStat(self, ...)
	end

	local setSpellHit = PaperDollFrame_SetSpellHitChance
	function PaperDollFrame_SetSpellHitChance(self, ...)
		if(class == 5 and spec ~= 3) then
			return self:Hide()
		elseif((class == 11 or class == 7) and spec == 3) then
			return self:Hide()
		end

		setSpellHit(self, ...)
	end

	local setParry = PaperDollFrame_SetParry
	function PaperDollFrame_SetParry(self, ...)
		if(class ~= 2 and class ~= 1 and class ~= 6 and not (class == 10 and spec == 2)) then
			return self:Hide()
		end

		setParry(self, ...)
	end

	local setBlock = PaperDollFrame_SetBlock
	function PaperDollFrame_SetBlock(self, ...)
		if(class ~= 2 and class ~= 1) then
			return self:Hide()
		end

		setBlock(self, ...)
	end
end
