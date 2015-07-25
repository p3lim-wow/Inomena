local E, F = unpack(select(2, ...))

local debugging = false
function F:Debug(...)
	if(debugging) then
		print('|cff00ff00Inomena|r:', ...)
	end
end

function F:Error(...)
	print('|cffff9999Inomena|r:', ...)
end

function F:Print(...)
	print('|cff0090ffInomena|r:', ...)
end
