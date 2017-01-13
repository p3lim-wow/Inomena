local E = unpack(select(2, ...))

local barrels = {}

local function numBarrels()
	-- would really want Lua 5.2 for this :/
	local count = 0
	for _ in next, barrels do
		count = count + 1
	end

	return count
end

local function MarkBarrels()
	local guid = UnitGUID('mouseover')
	if(guid) then
		if(tonumber(string.match(guid, 'Creature%-.-%-.-%-.-%-.-%-(.-)%-')) == 115947) then
			if(not barrels[guid]) then
				local index = (numBarrels() % 8) + 1
				barrels[guid] = index

				if(GetRaidTargetIndex('mouseover') ~= index) then
					SetRaidTarget('mouseover', index)
				end
			end
		end
	end
end

local quests = ' 45068 45069 45070 45071 45072 '
local function Reset(questID)
	if(quests:match(' ' .. questID .. ' ')) then
		table.wipe(barrels)
		E:UnregisterEvent('UPDATE_MOUSEOVER_UNIT', MarkBarrels)
		return true
	end
end

function E:UPDATE_OVERRIDE_ACTIONBAR()
	if(HasExtraActionBar()) then
		local _, spellID = GetActionInfo(ExtraActionButton1.action)
		if(spellID == 230884) then
			E:RegisterEvent('UPDATE_MOUSEOVER_UNIT', MarkBarrels)
			E:RegisterEvent('QUEST_REMOVED', Reset)
		end
	end
end
