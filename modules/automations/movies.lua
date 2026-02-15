local _, addon = ...

-- skip seen movies

function addon:PLAY_MOVIE(movieID)
	if not InomenaSeen then
		InomenaSeen = {
			movies = {},
		}
	end

	if InomenaSeen.movies[movieID] then
		MovieFrame:Hide() -- should be safe
		addon:Print('Skipped movie', movieID)
	else
		InomenaSeen.movies[movieID] = true
	end
end
