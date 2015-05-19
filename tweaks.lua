local _, Inomena = ...

Inomena.RegisterEvent('MERCHANT_SHOW', function()
	if(CanMerchantRepair() and not IsShiftKeyDown()) then
		RepairAllItems(CanGuildBankRepair() and CanWithdrawGuildBankMoney() and GetGuildBankWithdrawMoney() >= GetRepairAllCost())
	end
end)

Inomena.RegisterEvent('PLAYER_REGEN_ENABLED', function()
	UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end)

Inomena.RegisterEvent('PLAYER_REGEN_DISABLED', function()
	UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end)

Inomena.RegisterEvent('ADDON_LOADED', function(addon)
	if(addon == 'Blizzard_AchievementUI') then
		AchievementFrame_SetFilter(3)
	elseif(addon == 'Blizzard_GuildUI') then
		GuildFrame:HookScript('OnShow', function()
			GuildFrameTab2:Click()
		end)
	elseif(addon == 'Blizzard_ArchaeologyUI') then
		ArcheologyDigsiteProgressBar:ClearAllPoints()
		ArcheologyDigsiteProgressBar:SetPoint('TOP', 0, -50)
	end
end)

Inomena.RegisterEvent('REPLACE_ENCHANT', function()
	if(TradeSkillFrame and TradeSkillFrame:IsShown()) then
		ReplaceEnchant()
		StaticPopup_Hide('REPLACE_ENCHANT')
	end
end)

StaticPopupDialogs.DELETE_GOOD_ITEM.hasEditBox = false
StaticPopupDialogs.DELETE_GOOD_ITEM.OnShow = function(self)
	self.button1:Enable()
end

Inomena.RegisterEvent('BANKFRAME_OPENED', function()
	if(not IsShiftKeyDown()) then
		DepositReagentBank()
	end
end)

Inomena.RegisterEvent('PARTY_INVITE_REQUEST', function(name, l, f, g)
	if(QueueStatusMinimapButton:IsShown()) then return end
	if(l or f or g) then return end

	for index = 1, select(2, GetNumGuildMembers()) do
		if(string.split('-', (GetGuildRosterInfo(index))) == name) then
			return AcceptGroup()
		end
	end

	for index = 1, select(2, BNGetNumFriends()) do
		if(string.match(select(5, BNGetFriendInfo(index)), name)) then
			return AcceptGroup()
		end
	end

	for index = 1, GetNumFriends() do
		if(GetFriendInfo(index) == name) then
			return AcceptGroup()
		end
	end
end)

Inomena.RegisterEvent('PARTY_LEADER_CHANGED', function()
	if(StaticPopup_Visible('PARTY_INVITE')) then
		StaticPopup_Hide('PARTY_INVITE')
	elseif(StaticPopup_Visible('PARTY_INVITE_XREALM')) then
		StaticPopup_Hide('PARTY_INVITE_XREALM')
	end
end)

local soundFile = [[Sound\Interface\ReadyCheck.ogg]]
Inomena.RegisterEvent('UPDATE_BATTLEFIELD_STATUS', function()
	if(StaticPopup_Visible('CONFIRM_BATTLEFIELD_ENTRY')) then
		PlaySoundFile(soundFile, 'Master')
	end
end)

Inomena.RegisterEvent('LFG_PROPOSAL_SHOW', function()
	PlaySoundFile(soundFile, 'Master')
end)

ReadyCheckListenerFrame:SetScript('OnShow', function()
	PlaySoundFile(soundFile, 'Master')
end)

Inomena.RegisterEvent('PARTY_INVITE_REQUEST', function()
	PlaySoundFile(soundFile, 'Master')
end)

Inomena.RegisterEvent('LFG_LIST_APPLICATION_STATUS_UPDATED', function(_, status)
	if(status == 'invited') then
		PlaySoundFile(soundFile, 'Master')
	end
end)

Inomena.RegisterEvent('CHAT_MSG_RAID_BOSS_WHISPER', function(msg, name)
	if(name == UnitName('player') and msg == 'You are next in line!') then
		PlaySoundFile(soundFile, 'Master')
	end
end)

local recentlySpotted = {}
Inomena.RegisterEvent('VIGNETTE_ADDED', function(id)
	if(id and not recentlySpotted[id]) then
		local x, y, name, iconID = C_Vignettes.GetVignetteInfoFromInstanceID(id)
		if(iconID == 40) then
			return
		end

		name = name or 'Unknown Rare'

		RaidNotice_AddMessage(RaidWarningFrame, name .. ' spotted!', ChatTypeInfo.RAID_WARNING)
		PlaySoundFile(soundFile, 'Master')

		recentlySpotted[id] = true
	end
end)

Inomena.RegisterEvent('CINEMATIC_START', function()
	SetCVar('Sound_EnableMusic', 1)
	SetCVar('Sound_EnableAmbience', 1)
	SetCVar('Sound_EnableSFX', 1)

	if(IsInInstance()) then
		if(not InomenaCinematics) then
			InomenaCinematics = {}
		end

		SetMapToCurrentZone()
		local _, _, _, _, _, _, _, zone = GetInstanceInfo()
		local floor = GetCurrentMapDungeonLevel() or 0
		if(InomenaCinematics[zone .. floor]) then
			CinematicFrame_CancelCinematic()
		else
			InomenaCinematics[zone .. floor] = true
		end
	end
end)

Inomena.RegisterEvent('PLAY_MOVIE', function(id)
	if(IsInInstance()) then
		local _, _, _, _, _, _, _, zone = GetInstanceInfo()
		if(InomenaCinematics[zone .. id]) then
			MovieFrame_OnMovieFinished(MovieFrame)
		else
			InomenaCinematics[zone .. id] = true
		end
	end
end)

Inomena.RegisterEvent('CINEMATIC_STOP', function()
	SetCVar('Sound_EnableMusic', 0)
	SetCVar('Sound_EnableAmbience', 0)
	SetCVar('Sound_EnableSFX', 0)
end)

local CoordText
local totalElapsed = 0
local function UpdateCoords(self, elapsed)
	if(totalElapsed > 0.1) then
		if(WorldMapScrollFrame:IsMouseOver()) then
			local scale = self:GetEffectiveScale()
			local centerX, centerY = self:GetCenter()
			local width, height = self:GetSize()
			local x, y = GetCursorPosition()

			x = ((x / scale) - (centerX - (width / 2))) / width
			y = (centerY + (height / 2) - (y / scale)) / height

			CoordText:SetFormattedText('%.2f, %.2f', x * 100, y * 100)
			CoordText:SetTextColor(0, 1, 0)
		else
			local x, y = GetPlayerMapPosition('player')
			CoordText:SetFormattedText('%.2f, %.2f', x * 100, y * 100)
			CoordText:SetTextColor(1, 1, 0)
		end

		totalElapsed = 0
	else
		totalElapsed = totalElapsed + elapsed
	end
end

Inomena.RegisterEvent('PLAYER_LOGIN', function()
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint('TOPLEFT', 50, -142)
	ObjectiveTrackerFrame:SetHeight(700)

	ObjectiveTrackerFrame.ClearAllPoints = Inomena.noop
	ObjectiveTrackerFrame.SetPoint = Inomena.noop

	CoordText = WorldMapFrameCloseButton:CreateFontString(nil, nil, 'GameFontNormal')
	CoordText:SetPoint('RIGHT', WorldMapFrameCloseButton, 'LEFT', -30, 0)

	WorldMapDetailFrame:HookScript('OnUpdate', UpdateCoords)

	WorldMapPlayerUpper:EnableMouse(false)
	WorldMapPlayerLower:EnableMouse(false)
end)

QueueStatusMinimapButton.EyeHighlightAnim:SetScript('OnLoop', nil)

StaticPopupDialogs.PARTY_INVITE.hideOnEscape = 0
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = 0

VehicleSeatIndicator:UnregisterAllEvents()
VehicleSeatIndicator:Hide()

UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')

TemporaryEnchantFrame:Hide()
TemporaryEnchantFrame:UnregisterAllEvents()
