local _, addon = ...

local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS or 10 -- FrameXML/ChatFrame.lua
local CHAT_FRAME_TEXTURES = _G.CHAT_FRAME_TEXTURES -- FrameXML/FloatingChatFrame.lua

local function updateTab(tab)
	if tab:GetObjectType() ~= 'Button' then
		tab = _G[tab:GetName() .. 'Tab']
	end

	local tabID = tab:GetID()
	if tabID < 1 then
		return
	end

	local chatFrame = _G['ChatFrame' .. tabID]
	if chatFrame.isTemporary and chatFrame.chatType == 'PET_BATTLE_COMBAT_LOG' then
		if tab:IsMouseOver() then
			tab.Text:SetText('|A:WildBattlePet:20:20|a')
		else
			tab.Text:SetText('|A:WildBattlePetCapturable:20:20|a')
		end
	else
		if tab:IsMouseOver() then
			tab.Text:SetTextColor(0, 0.6, 1)
		elseif tab.alerting then
			tab.Text:SetTextColor(1, 0, 0)
		elseif tabID == SELECTED_CHAT_FRAME:GetID() then
			tab.Text:SetTextColor(1, 1, 1)
		else
			tab.Text:SetTextColor(0.5, 0.5, 0.5)
		end
	end
end

local modifiedTabs = {}
local function modifyTab(tab)
	if modifiedTabs[tab] then
		return
	else
		modifiedTabs[tab] = true
	end

	if tab:GetID() <= NUM_CHAT_WINDOWS then
		-- disable middle click on all tabs that are not temporary
		tab:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	end

	tab:RegisterForDrag() -- disable dragging
	tab:HookScript('OnEnter', updateTab)
	tab:HookScript('OnLeave', updateTab)

	for _, child in next, {tab:GetRegions()} do
		if child:GetObjectType() == 'Texture' then
			child:SetTexture(nil)
		end
	end
end

hooksecurefunc('FCFTab_UpdateColors', updateTab)
hooksecurefunc('FCF_StartAlertFlash', updateTab)

for index = 1, NUM_CHAT_WINDOWS do
	modifyTab(_G['ChatFrame' .. index .. 'Tab'])

	-- hide chat frame background crap too
	for _, texture in next, CHAT_FRAME_TEXTURES do
		addon:Hide('ChatFrame' .. index .. texture)
	end
end

hooksecurefunc('FCF_SetTemporaryWindowType', function(chatFrame)
	modifyTab(_G[chatFrame:GetName() .. 'Tab'])
end)
