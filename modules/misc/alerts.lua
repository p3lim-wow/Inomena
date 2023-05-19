local addonName, addon = ...

local IDLE_MESSAGE = _G.IDLE_MESSAGE -- globalstring

local lastAlertTime = 0
local function alert()
	if GetTime() >= lastAlertTime + 10 then -- avoid spam
		PlaySound(8960, 'master') -- SOUNDKIT.READY_CHECK
		-- FlashClientIcon()
		lastAlertTime = GetTime()
	end
end

-- battleground queue pop
function addon:UPDATE_BATTLEFIELD_STATUS(index)
	if GetBattlefieldStatus(index) == 'confirm' then
		alert()
	end
end

-- lfg queue pop
function addon:LFG_LIST_APPLICATION_STATUS_UPDATED(_, status)
	if status == 'invited' then
		alert()
	end
end

function addon:CHAT_MSG_RAID_BOSS_WHISPER(msg, name)
	-- Brawler's Guild queue
	if name == UnitName('player') and msg == 'You are next in line!' then
		alert()
	end
end

-- combat state changes
function addon:PLAYER_REGEN_ENABLED()
	UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end

function addon:PLAYER_REGEN_DISABLED()
	UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end

-- afk logout popup
function addon:CHAT_MSG_SYSTEM(msg)
	if msg == IDLE_MESSAGE then
		alert()
	end
end

-- readychecks
ReadyCheckListenerFrame:SetScript('OnShow', alert)

-- invites
addon:RegisterEvent('PARTY_INVITE_REQUEST', alert)
addon:RegisterEvent('LFG_PROPOSAL_SHOW', alert)

-- feast "alert"
local FEAST_MESSAGE = '%s placed a feast'
local FEASTS = {
	[381420] = true, -- Hoard of Draconic Delicacies
	[382423] = true, -- Yusa's Hearty Stew
	[382427] = true, -- Grand Banquet of the Kalu'ak
}

local function feastWrapper(_, _, casterName, _, _, _, _, _, _, spellID)
	if FEASTS[spellID] and IsInInstance() then -- SAY is protected in the open world
		SendChatMessage(FEAST_MESSAGE:format(casterName), 'SAY')
	end
end

function addon:PLAYER_REGEN_DISABLED()
	self:UnregisterCombatEvent('SPELL_CAST_SUCCESS', feastWrapper)
end

function addon:PLAYER_REGEN_ENABLED()
	self:RegisterCombatEvent('SPELL_CAST_SUCCESS', feastWrapper)
end

addon:RegisterCombatEvent('SPELL_CAST_SUCCESS', feastWrapper)

-- party/raid member death alerts
local DEATH_SOUND = ([[Interface\AddOns\%s\assets\crow.mp3]]):format(addonName)

local function IsInDungeonOrRaid()
	local inInstance, instanceType = IsInInstance()
	return inInstance and (instanceType == 'party' or instanceType == 'raid')
end

local numDead = 0
addon:RegisterCombatEvent('UNIT_DIED', function(_, _, _, _, _, destGUID, destName)
	if destName and IsInDungeonOrRaid() and C_PlayerInfo.GUIDIsPlayer(destGUID) and not UnitIsFeignDeath(destName) then
		local unit = UnitTokenFromGUID(destGUID)
		if unit and (UnitInRaid(unit) or UnitInParty(unit)) then
			if IsInRaid() then
				numDead = numDead + 1
				if numDead > GetNumGroupMembers() / 2 then
					-- by then it must have been called a wipe
					return
				end
			end

			PlaySoundFile(DEATH_SOUND, 'master')
			addon:Print(destName, 'Died')
		end
	end
end)

addon:RegisterCombatEvent('ENCOUNTER_END', function()
	numDead = 0
end)

local TANAAN_QUEST_IDS = {
	-- vignetteID = questID
	[956] = 39288, -- Terrorfist
	[957] = 39289, -- Doomroller
	[958] = 39290, -- Vengeance
	[959] = 39287, -- Deathtalon
}

local seen = {}
function addon:VIGNETTES_UPDATED()
	for _, guid in next, C_VignetteInfo.GetVignettes() do
		local info = C_VignetteInfo.GetVignetteInfo(guid)
		if info and info.vignetteID then
			local questID = TANAAN_QUEST_IDS[info.vignetteID]
			if questID and not C_QuestLog.IsQuestFlaggedCompleted(questID) and not seen[info.vignetteID] then
				alert()
				seen[info.vignetteID] = true -- to avoid sound spam
			end
		end
	end
end
