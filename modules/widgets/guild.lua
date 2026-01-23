local _, addon = ...

-- add guild invite option to unit dropdown menu

-- store existing guild members
local members = addon:T()
function addon:GUILD_ROSTER_UPDATE()
	members:wipe()

	for index = 1, (GetNumGuildMembers()) do
		local name = GetGuildRosterInfo(index)
		if name then
			-- the name contains realm name
			members[name] = true
		end
	end
end

local LINE_TEXT = CHAT_GUILD_INVITE_SEND:gsub(HEADER_COLON, '')

Menu.ModifyMenu('MENU_UNIT_FRIEND', function(_, menu, data)
	local name = data.name
	if data.server then
		name = name .. '-' .. data.server
	else
		-- we need to use full name with realm for everyone
		name = name .. '-' .. addon.PLAYER_REALM
	end

	if members[name] then
		-- C_GuildInfo.MemberExistsByName doesn't support realm names, even though
		-- all guilds are now region wide, so it's practically useless
		return
	end

	menu:Insert(MenuUtil.CreateButton(LINE_TEXT, GenerateClosure(C_GuildInfo.Invite, name)), 6)
end)

Menu.ModifyMenu('MENU_UNIT_PLAYER', function(_, menu, data)
	if not data.unit or not UnitIsFriend('player', data.unit) or GetGuildInfo(data.unit) then
		return
	end

	menu:Insert(MenuUtil.CreateButton(LINE_TEXT, GenerateClosure(C_GuildInfo.Invite, GetUnitName(data.unit, true))), 8)
end)
