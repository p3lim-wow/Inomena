local E, F, C = unpack(select(2, ...))

-- sourced from WorldQuestGroupFinder 0.22.6, RIP
local raidQuests = {
	-- Normal quests
	[42820] = true, -- DANGER: Aegir Wavecrusher
	[41685] = true, -- DANGER: Ala'washte
	[44113] = true, -- DANGER: Anachronos
	[43091] = true, -- DANGER: Arcanor Prime
	[44118] = true, -- DANGER: Auditor Esiel
	[44121] = true, -- DANGER: Az'jatar
	[44189] = true, -- DANGER: Bestrix
	[42861] = true, -- DANGER: Boulderfall, the Eroded
	[42864] = true, -- DANGER: Captain Dargun
	[43121] = true, -- DANGER: Chief Treasurer Jabrill
	[41697] = true, -- DANGER: Colerian, Alteria, and Selenyi
	[43175] = true, -- DANGER: Deepclaw
	[41695] = true, -- DANGER: Defilia
	[42785] = true, -- DANGER: Den Mother Ylva
	[41093] = true, -- DANGER: Durguth
	[43346] = true, -- DANGER: Ealdis
	[43059] = true, -- DANGER: Fjordun
	[42806] = true, -- DANGER: Fjorlag, the Grave's Chill
	[43345] = true, -- DANGER: Harbinger of Screams
	[43079] = true, -- DANGER: Immolian
	[44190] = true, -- DANGER: Jade Darkhaven
	[44191] = true, -- DANGER: Karthax
	[43798] = true, -- DANGER: Kosumoth the Hungering
	[42964] = true, -- DANGER: Lagertha
	[44192] = true, -- DANGER: Lysanis Shadesoul
	[43152] = true, -- DANGER: Lytheron
	[44114] = true, -- DANGER: Magistrix Vilessa
	[42927] = true, -- DANGER: Malisandra
	[43098] = true, -- DANGER: Marblub the Massive
	[41696] = true, -- DANGER: Mawat'aki
	[43027] = true, -- DANGER: Mortiferous
	[43333] = true, -- DANGER: Nylaathria the Forgotten
	[41703] = true, -- DANGER: Ormagrogg
	[41816] = true, -- DANGER: Oubdob da Smasher
	[43347] = true, -- DANGER: Rabxach
	[42963] = true, -- DANGER: Rulf Bonesnapper
	[42991] = true, -- DANGER: Runeseer Sigvid
	[42797] = true, -- DANGER: Scythemaster Cil'raman
	[44193] = true, -- DANGER: Sea King Tidross
	[41700] = true, -- DANGER: Shalas'aman
	[44122] = true, -- DANGER: Sorallus
	[42953] = true, -- DANGER: Soulbinder Halldora
	[43072] = true, -- DANGER: The Whisperer
	[44194] = true, -- DANGER: Torrentius
	[43040] = true, -- DANGER: Valakar the Thirsty
	[44119] = true, -- DANGER: Volshax, Breaker of Will
	[43101] = true, -- DANGER: Withdoctor Grgl-Brgl
	[41779] = true, -- DANGER: Xavrix
	[44017] = true, -- WANTED: Apothecary Faldren
	[44032] = true, -- WANTED: Apothecary Faldren
	[42636] = true, -- WANTED: Arcanist Shal'iman
	[43605] = true, -- WANTED: Arcanist Shal'iman
	[42620] = true, -- WANTED: Arcavellus
	[43606] = true, -- WANTED: Arcavellus
	[41824] = true, -- WANTED: Arru
	[44289] = true, -- WANTED: Arru
	[44301] = true, -- WANTED: Bahagar
	[44305] = true, -- WANTED: Bahagar
	[41836] = true, -- WANTED: Bodash the Hoarder
	[43616] = true, -- WANTED: Bodash the Hoarder
	[41828] = true, -- WANTED: Bristlemaul
	[44290] = true, -- WANTED: Bristlemaul
	[43426] = true, -- WANTED: Brogozog
	[43607] = true, -- WANTED: Brogozog
	[42796] = true, -- WANTED: Broodmother Shu'malis
	[44016] = true, -- WANTED: Cadraeus
	[44031] = true, -- WANTED: Cadraeus
	[43430] = true, -- WANTED: Captain Volo'ren
	[43608] = true, -- WANTED: Captain Volo'ren
	[41826] = true, -- WANTED: Crawshuk the Hungry
	[44291] = true, -- WANTED: Crawshuk the Hungry
	[44299] = true, -- WANTED: Darkshade
	[44304] = true, -- WANTED: Darkshade
	[43455] = true, -- WANTED: Devouring Darkness
	[43617] = true, -- WANTED: Devouring Darkness
	[43428] = true, -- WANTED: Doomlord Kazrok
	[43609] = true, -- WANTED: Doomlord Kazrok
	[44298] = true, -- WANTED: Dreadbog
	[44303] = true, -- WANTED: Dreadbog
	[43454] = true, -- WANTED: Egyl the Enduring
	[43620] = true, -- WANTED: Egyl the Enduring
	[43434] = true, -- WANTED: Fathnyr
	[43621] = true, -- WANTED: Fathnyr
	[43436] = true, -- WANTED: Glimar Ironfist
	[43622] = true, -- WANTED: Glimar Ironfist
	[44030] = true, -- WANTED: Guardian Thor'el
	[44013] = true, -- WANTED: Guardian Thor'el
	[41819] = true, -- WANTED: Gurbog da Basher
	[43618] = true, -- WANTED: Gurbog da Basher
	[43453] = true, -- WANTED: Hannval the Butcher
	[43623] = true, -- WANTED: Hannval the Butcher
	[44021] = true, -- WANTED: Hertha Grimdottir
	[44029] = true, -- WANTED: Hertha Grimdottir
	[43427] = true, -- WANTED: Infernal Lord
	[43610] = true, -- WANTED: Infernal Lord
	[43611] = true, -- WANTED: Inquisitor Tivos
	[42631] = true, -- WANTED: Inquisitor Tivos
	[43452] = true, -- WANTED: Isel the Hammer
	[43624] = true, -- WANTED: Isel the Hammer
	[43460] = true, -- WANTED: Kiranys Duskwhisper
	[43629] = true, -- WANTED: Kiranys Duskwhisper
	[44028] = true, -- WANTED: Lieutenant Strathmar
	[44019] = true, -- WANTED: Lieutenant Strathmar
	[44018] = true, -- WANTED: Magister Phaedris
	[44027] = true, -- WANTED: Magister Phaedris
	[41818] = true, -- WANTED: Majestic Elderhorn
	[44292] = true, -- WANTED: Majestic Elderhorn
	[44015] = true, -- WANTED: Mal'Dreth the Corruptor
	[44026] = true, -- WANTED: Mal'Dreth the Corruptor
	[43438] = true, -- WANTED: Nameless King
	[43625] = true, -- WANTED: Nameless King
	[43432] = true, -- WANTED: Normantis the Deposed
	[43612] = true, -- WANTED: Normantis the Deposed
	[41686] = true, -- WANTED: Olokk the Shipbreaker
	[44010] = true, -- WANTED: Oreth the Vile
	[43458] = true, -- WANTED: Perrexx
	[43630] = true, -- WANTED: Perrexx
	[42795] = true, -- WANTED: Sanaar
	[44300] = true, -- WANTED: Seersei
	[44302] = true, -- WANTED: Seersei
	[41844] = true, -- WANTED: Sekhan
	[44294] = true, -- WANTED: Sekhan
	[44022] = true, -- WANTED: Shal'an
	[41821] = true, -- WANTED: Shara Felbreath
	[43619] = true, -- WANTED: Shara Felbreath
	[44012] = true, -- WANTED: Siegemaster Aedrin
	[44023] = true, -- WANTED: Siegemaster Aedrin
	[43456] = true, -- WANTED: Skul'vrax
	[43631] = true, -- WANTED: Skul'vrax
	[41838] = true, -- WANTED: Slumber
	[44293] = true, -- WANTED: Slumber
	[43429] = true, -- WANTED: Syphonus
	[43613] = true, -- WANTED: Syphonus
	[43437] = true, -- WANTED: Thane Irglov
	[43626] = true, -- WANTED: Thane Irglov
	[43457] = true, -- WANTED: Theryssia
	[43632] = true, -- WANTED: Theryssia
	[43459] = true, -- WANTED: Thondrax
	[43633] = true, -- WANTED: Thondrax
	[43450] = true, -- WANTED: Tiptog the Lost
	[43627] = true, -- WANTED: Tiptog the Lost
	[43451] = true, -- WANTED: Urgev the Flayer
	[43628] = true, -- WANTED: Urgev the Flayer
	[42633] = true, -- WANTED: Vorthax
	[43614] = true, -- WANTED: Vorthax
	[43431] = true, -- WANTED: Warbringer Mox'na

	-- World bosses
	[46945] = true, -- Si'vash
	[47061] = true, -- Apocron
	[46948] = true, -- Malificus
	[42270] = true, -- Scourge of the Skies
	[44287] = true, -- DEADLY: Withered J'im
	[43192] = true, -- Terror of the Deep
	[43448] = true, -- The Frozen King
	[43193] = true, -- Calamitous Intent
	[42779] = true, -- The Sleeping Corruption
	[42269] = true, -- The Soultakers
	[42819] = true, -- Pocket Wizard
	[42270] = true, -- Scourge of the Skies
	[43512] = true, -- Ana-Mouz
	[43985] = true, -- A Dark Tide
}


-- Popup to leave group after WQ finished
function E:QUEST_TURNED_IN(questID)
	if(IsInGroup(LE_PARTY_CATEGORY_HOME) and QuestUtils_IsQuestWorldQuest(questID)) then
		StaticPopup_Show('INOMENA_LEAVE_QUEST_GROUP')
	end
end

-- Popup to warn when joined a raid for non-raid quests
local warned
local function RaidWarning()
	local questID = select(11, C_LFGList.GetActiveEntryInfo())
	if(questID and QuestUtils_IsQuestWorldQuest(questID)) then
		if(IsInRaid(LE_PARTY_CATEGORY_HOME) and not raidQuests[questID]) then
			warned = true
			StaticPopup_Show('INOMENA_LEAVE_RAID_QUEST_GROUP')
		end
	end
end

E:RegisterEvent('GROUP_JOINED', RaidWarning)
E:RegisterEvent('GROUP_ROSTER_UPDATE', RaidWarning)

function E:GROUP_LEFT()
	warned = false
end

-- Hide auto-convert popups
hooksecurefunc('StaticPopup_Show', function(which)
	if(which == 'LFG_LIST_AUTO_ACCEPT_CONVERT_TO_RAID') then
		local questID = select(11, C_LFGList.GetActiveEntryInfo())
		if(questID and QuestUtils_IsQuestWorldQuest(questID)) then
			StaticPopup_Hide(which)

			if(raidQuests[questID]) then
				-- Auto convert for raid quests
				ConvertToRaid()
			end
		end
	end
end)

-- Hide acknowledge popup when joining groups
hooksecurefunc('LFGListInviteDialog_Show', function(self, resultID)
	if(self.AcknowledgeButton:IsShown()) then
		LFGListInviteDialog_Acknowledge(self)
	end
end)

-- Popups
local LEAVE_GROUP = PARTY_LEAVE .. "? (%d)" -- Leave party? (%d)
StaticPopupDialogs.INOMENA_LEAVE_QUEST_GROUP = {
	text = string.format(LEAVE_GROUP, 10),
	button1 = PET_WAIT, -- "Stay"
	button2 = CHAT_LEAVE, -- "Leave"
	OnShow = function(self)
		self.timeleft = 10
	end,
	OnCancel = function()
		LeaveParty()
	end,
	OnUpdate = function(self, elapsed)
		self.text:SetFormattedText(LEAVE_GROUP, self.timeleft + 1)
	end,
	timeout = 10,
	hideOnEscape = 0,
	whileDead = true,
}

StaticPopupDialogs.INOMENA_LEAVE_RAID_QUEST_GROUP = {
	text = string.format('|cffff0000%s|r', ERR_PARTY_CONVERTED_TO_RAID), -- "Party converted to Raid"
	button1 = CHAT_LEAVE, -- "Leave"
	button2 = PET_WAIT, -- "Stay"
	OnAccept = function()
		LeaveParty()
	end,
	hideOnEscape = 0,
	whileDead = true,
}
