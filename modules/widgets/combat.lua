local _, addon = ...

-- display combat state changes

function addon:PLAYER_REGEN_ENABLED()
	UIErrorsFrame:AddMessage('- Combat', 1, 1, 1)
end

function addon:PLAYER_REGEN_DISABLED()
	UIErrorsFrame:AddMessage('+ Combat', 1, 1, 1)
end
