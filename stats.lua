
local orig = PaperDoll_InitStatCategories
local _, class = UnitClass('player')

local brute = class == 'DEATHKNIGHT' or class == 'PALADIN' or class == 'WARRIOR'
local block = class == 'PALADIN' or class == 'WARRIOR'
local parry = class == 'DEATHKNIGHT'

PAPERDOLL_STATCATEGORIES = {
	GENERAL = {
		id = 1,
		stats = {
			'ITEMLEVEL',
			'MOVESPEED',
		}
	},
	MELEE = {
		id = 2,
		stats = brute and {
			'STRENGTH',
			'AGILITY',
			'MELEE_AP',
			'MELEE_ATTACKSPEED',
			'RUNE_REGEN',
			'HASTE',
			'CRITCHANCE',
			'HITCHANCE',
			'EXPERTISE',
			'MASTERY',
		} or {
			'AGILITY',
			'MELEE_AP',
			'MELEE_ATTACKSPEED',
			'ENERGY_REGEN',
			'HASTE',
			'CRITCHANCE',
			'HITCHANCE',
			'EXPERTISE',
			'MASTERY',
		}
	},
	RANGED = {
		id = 2,
		stats = {
			'AGILITY',
			'RANGED_AP',
			'RANGED_ATTACKSPEED',
			'RANGED_HASTE',
			'FOCUS_REGEN',
			'RANGED_CRITCHANCE',
			'RANGED_HITCHANCE',
			'MASTERY',
		}
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
			'MASTERY',
		}
	},
	DEFENSE = {
		id = 3,
		stats = block and {
			'STAMINA',
			'ARMOR',
			'DODGE',
			'PARRY',
			'BLOCK',
			'RESILIENCE_REDUCTION',
		} or parry and {
			'STAMINA',
			'ARMOR',
			'DODGE',
			'PARRY',
			'RESILIENCE_REDUCTION',
		} or {
			'STAMINA',
			'ARMOR',
			'DODGE',
			'RESILIENCE_REDUCTION',
		}
	},
	RESISTANCE = {
		id = 4,
		stats = {
			'ARCANE',
			'FIRE',
			'FROST',
			'NATURE',
			'SHADOW',
			'SPELL_PENETRATION',
		}
	}
}

local healer = PAPERDOLL_STATCATEGORIES.SPELL.stats
local caster = {
	'SPRIT',
	'INTELLECT',
	'SPELLDAMAGE',
	'SPELL_HASTE',
	'MANAREGEN',
	'SPELLCRIT',
	'SPELL_HITCHANCE',
	'MASTERY',
}

local sort = {
	{
		'GENERAL',
		'MELEE',
		'DEFENSE',
		'RESISTANCE',
	},
	{
		'GENERAL',
		'RANGED',
		'DEFENSE',
		'RESISTANCE',
	},
	{
		'GENERAL',
		'SPELL',
		'DEFENSE',
		'RESISTANCE',
	},
}

local classes = {
	DEATHKNIGHT = {1, 1, 1},
	DRUID = {3, 1, 3},
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
	local tabs = GetNumTalentTabs()
	if(tabs == 0) then return end

	local mostPoints = -1
	local spec

	for index = 1, tabs do
		local _, _, _, _, points = GetTalentTabInfo(index)
		if(points > mostPoints) then
			mostPoints = points
			spec = index
		end
	end

	if(class == 'PRIEST') then
		if(spec == 3) then
			PAPERDOLL_STATCATEGORIES.SPELL.stats = caster
		else
			PAPERDOLL_STATCATEGORIES.SPELL.stats = healer
		end
	elseif(class == 'DRUID' or class == 'SHAMAN') then
		if(spec == 1) then
			PAPERDOLL_STATCATEGORIES.SPELL.stats = caster
		elseif(spec == 3) then
			PAPERDOLL_STATCATEGORIES.SPELL.stats = healer
		end
	end

	PaperDoll_InitStatCategories = function()
		orig(sort[classes[class][spec]], nil, nil, 'player')
		PaperDollFrame_CollapseStatCategory(CharacterStatsPaneCategory4)
	end
end)

for index = 1, 4 do
	local toolbar = _G['CharacterStatsPaneCategory' .. index .. 'Toolbar']
	toolbar:SetScript('OnEnter', nil)
	toolbar:RegisterForDrag()
end
