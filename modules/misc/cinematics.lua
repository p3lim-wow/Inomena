local E, F = unpack(select(2, ...))

function E:CINEMATIC_START()
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
end

function E:PLAY_MOVIE(id)
	if(IsInInstance()) then
		local _, _, _, _, _, _, _, zone = GetInstanceInfo()
		if(InomenaCinematics[zone .. id]) then
			MovieFrame_OnMovieFinished(MovieFrame)
		else
			InomenaCinematics[zone .. id] = true
		end
	end
end

function E:CINEMATIC_STOP()
	SetCVar('Sound_EnableMusic', 0)
	SetCVar('Sound_EnableAmbience', 0)
	SetCVar('Sound_EnableSFX', 0)
end
