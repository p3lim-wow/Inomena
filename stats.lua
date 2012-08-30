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
			'RANGED_CRITCHANCE',
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
			'SPELL_CRITCHANCE',
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
		},
	},
}

local orig = PaperDoll_InitStatCategories
local class = select(2, UnitClass('player'))

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
local classes = {
	DEATHKNIGHT = {1, 1, 1},
	DRUID = {3, 1, 1, 3},
	HUNTER = {2, 2, 2},
	MAGE = {3, 3, 3},
	PALADIN = {3, 1, 1},
	PRIEST = {3, 3, 3},
	ROGUE = {1, 1, 1},
	SHAMAN = {3, 1, 3},
	WARLOCK = {3, 3, 3},
	WARRIOR = {1, 1, 1},
}

local handler = CreateFrame('Frame')
handler:RegisterEvent('PLAYER_TALENT_UPDATE')
handler:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
handler:SetScript('OnEvent', function()
	local spec = GetSpecialization()

	if(spec) then
		PaperDoll_InitStatCategories = function()
			orig(sort[classes[class][spec]], nil, nil, 'player')
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
	function PaperDollFrame_SetStat(self, unit, index)
		if(index == 1 and class ~= 'DEATHKNIGHT' and class ~= 'PALADIN' and class ~= 'WARRIOR') then
			return self:Hide()
		end

		setStat(self, unit, index)
	end

	local setSpellHit = PaperDollFrame_SetSpellHitChance
	function PaperDollFrame_SetSpellHitChance(self, unit)
		if(class == 'PRIEST' and spec ~= 3) then
			return self:Hide()
		elseif((class == 'DRUID' or class == 'SHAMAN') and spec == 3) then
			return self:Hide()
		end

		setSpellHit(self, unit)
	end

	local setParry = PaperDollFrame_SetParry
	function PaperDollFrame_SetParry(self, unit)
		if(class ~= 'PALADIN' and class ~= 'WARRIOR' and class ~= 'DEATHKNIGHT') then
			return self:Hide()
		end
	end

	local setBlock = PaperDollFrame_SetBlock
	function PaperDollFrame_SetBlock(self, unit)
		if(class ~= 'PALADIN' and class ~= 'WARRIOR') then
			return self:Hide()
		end
	end
end

