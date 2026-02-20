local _, addon = ...

-- auto-summon Pierre when cooking - it's a walking camp fire

local cachedGUID
local function getPierreGUID()
	if not cachedGUID then
		for _, guid in next, C_PetJournal.GetOwnedPetIDs() do
			local speciesID = C_PetJournal.GetPetInfoByPetID(guid)
			if speciesID == 1204 then -- Pierre
				cachedGUID = guid
				break
			end
		end
	end

	return cachedGUID
end

local function summonPierre()
	local petGUID = getPierreGUID()
	if petGUID and C_PetJournal.PetIsSummonable(petGUID) then
		local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
		if not summonedPetGUID or summonedPetGUID ~= petGUID then
			C_PetJournal.SummonPetByGUID(petGUID)
		end
	end
end

local function dismissPierre()
	local petGUID = getPierreGUID()
	if petGUID then
		local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
		if summonedPetGUID and summonedPetGUID == petGUID then
			C_PetJournal.SummonPetByGUID(petGUID) -- will dismiss it
		end
	end
end

addon:RegisterCallback('Professions.ProfessionSelected', function()
	local professionInfo = C_TradeSkillUI.GetBaseProfessionInfo()
	if professionInfo and professionInfo.professionID == 185 then -- Cooking
		addon:Defer(summonPierre)
	else
		addon:Defer(dismissPierre)
	end
end)

addon:RegisterCallback('ProfessionsFrame.Hide', function()
	addon:Defer(dismissPierre)
end)
