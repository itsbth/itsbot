command.SetSign("%")

local autojoin = {
	["irc.gamesurge.net"] = {
		"#wiremod",
		"#testobot",
	},
	-- Multinetwork does not work yet
	["irc.quakenet.org"] = {
		"#diskusjon.wow",
	}
}

hook.Add(function() for k,v in ipairs(autojoin[server]) do joinChannel(v) end end, hook.CONNECT, "JoinTesto")

function auth()
	sendMessage("AuthServ@Services.GameSurge.net", "AUTH itsbot " .. dofile("conf.lua").authserv.pass)
end
--hook.Add(auth, hook.CONNECT, "Auth")

admin.Load()

dofile("scripts/generic.lua")