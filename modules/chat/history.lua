local history = {}
local historyIndex = 0
local maxHistory = 50

local function addHistory(editBox, line)
	if not line or line == '' then
		return
	end

	local command = line:match('^(/%s+)')
	if command and IsSecureCmd(command) then
		-- we can't repeat secure commands in the chat
		return
	end

	for index = 1, #history do
		if history[index] == line then
			historyIndex = index + 1
		end
	end

	table.insert(history, line)

	if #history > maxHistory then
		table.remove(history, 1)
	end

	historyIndex = #history + 1
end

local function navigateHistory(editBox, key)
	if key ~= 'UP' and key ~= 'DOWN' then
		return
	end

	if #history == 0 then
		return
	end

	local index = historyIndex + (key == 'UP' and -1 or 1)
	if index < 1 then
		index = #history
	elseif index > #history then
		index = 1
	end

	historyIndex = index
	editBox:SetText(history[index])
end

local function resetHistoryIndex()
	historyIndex = 0
end

for index = 1, NUM_CHAT_WINDOWS do
	local editBox = _G['ChatFrame' .. index .. 'EditBox']
	editBox:HookScript('OnEscapePressed', resetHistoryIndex)
	editBox:HookScript('OnArrowPressed', navigateHistory)
	hooksecurefunc(editBox, 'AddHistoryLine', addHistory)
end
