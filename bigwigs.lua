local _, Inomena = ...

function Inomena.Initialize.BIGWIGS()
	local db = BigWigs3DB
	if(not db) then
		print('|cffff6000Inomena:|r Detected fresh install of BigWigs, please open BigWigs and /reload before injecting settings.')
	elseif(not db.profiles.PrettyWigs) then
		db.profiles.PrettyWigs = {
			raidicon = false,
			flash = false,
			shake = false,
			sound = false,
		}

		local profileKey = UnitName('player') .. ' - ' .. GetRealmName()
		db.profileKeys[profileKey] = 'PrettyWigs'

		db.namespaces.BigWigs_Plugins_Bars.profiles.PrettyWigs = {
			BigWigsAnchor_x = 612,
			BigWigsAnchor_y = 768,
			emphasizeFlash = false,
			emphasizeScale = 1,
			barStyle = 'PrettyWigs',
			texture = 'Flat',
			growup = false,
		}

		db.namespaces.BigWigs_Plugins_Proximity.profiles.PrettyWigs = {
			lock = true,
			posx = 630,
			posy = 278,
			width = 140,
			height = 140,
			objects = {
				title = false,
				close = false,
				sound = false,
				ability = false,
				tooltip = false,
				background = false,
			}
		}

		db.namespaces.BigWigs_Plugins_Messages.profiles.PrettyWigs = {
			sink20OutputSink = 'RaidWarning',
			emphasizedMessages = {
				sink20OutputSink = 'None',
			}
		}

		db.namespaces['BigWigs_Plugins_Tip of the Raid'].profiles.PrettyWigs = {
			show = false,
		}

		BigWigs3IconDB.hide = true
	end
end
