function exec(sender, channel, arg)
	local f, err = loadstring(arg)
	if not f then
		sendMessage(channel, "loadstring: " .. err)
		return
	end
	r, err = pcall(f)
	if not r then
		sendMessage(channel, "pcall: " .. err)
	end
end

command.Add("exec", exec, "Execute Lua", command.ALL, 10)

function reload(sender, channel, arg)
	sendMessage(channel, "Reloading scripts")
	dofile "simple.lua"
end

command.Add("reload", reload, "Reload scripts", command.ALL, 10)

function join(sender, channel, arg)
	local res = explode(" ", arg)
	for k,v in ipairs(res) do
		joinChannel(v)
	end
end

command.Add("join", join, "Joins a channel", command.ALL, 4)

function part(sender, channel, arg)
	local res = explode(" ", arg)
	local chan = res[1] or channel
	table.remove(res, 1)
	local reas = table.concat(res, " ")
	reas = reas or "Leaving..."
	partChannel(chan, reas)
end

command.Add("part", part, "Leaves a channel", command.ALL, 4)

function say(sender, channel, arg)
	local res = explode(" ", arg)
	local chan = res[1]
	table.remove(res, 1)
	sendMessage(chan, table.concat(res, " "))
end

command.Add("say", say, "Say something", command.ALL, 2)

local Time = {}

function psay(sender, channel, arg)
	local t = os.time()
	if Time[sender] == nil then Time[sender] = 0 end
	if (t - Time[sender]) < 60 then return sendMessage(sender, "You can't send a message so often. Time left " .. 60 - (t - Time[sender]) .. " seconds") end
	local res = explode(" ", arg)
	local chan = res[1]
	table.remove(res, 1)
	Time[sender] = t
	sendMessage(chan, sender .. ": " .. table.concat(res, " ") )
end

command.Add("psay", psay, "Say something (reveals sender)")

function action(sender, channel, arg)
	local res = explode(" ", arg)
	local chan = res[1]
	table.remove(res, 1)
	sendCTCPMessage(chan, "ACTION " .. table.concat(res, " "))
end

command.Add("action", action, "/me", command.ALL, 5)

function raw(sender, channel, arg)
	sendRaw(arg)
end

command.Add("raw", raw, "Sends a raw line to the server", command.ALL, 9)

function reCon(sender, channel, arg)
	if sender == "ITSBOT" then
		--sleep(10000)
		Sleep(10000)
		connect("irc.gamesurge.net")
	end
end

function save(sender, channel, arg)
	admin.Save()
	--response.Data:Save()
	ratings.Rates:Save()
end

command.Add("save", save, "Saves changes", command.ALL, 1)

function load(sender, channel, arg)
	admin.Load()
	response.Data:Load()
	ratings.Rates:Load()
end

command.Add("load", load, "Load changes", command.ALL, 1)

dofile("scripts/listen.lua")
dofile("scripts/response.lua")

admin.Load()

response.Data:Load()

function reset(sender, channel, arg)
	admin.Save()
	response.Data:Save()
	quitServer("Resetting (" .. sender ..")")
end

command.Add("reset", reset, "Resets the bot", command.ALL, 5)

dofile("scripts/ratings.lua")
--dofile("scripts/mchat.lua")
dofile("scripts/eval.lua")

ratings.Add("GoldStar")
ratings.Add("Dumb")
ratings.Add("Agree")
ratings.Add("Disagree")
ratings.Add("Friendly")
ratings.Add("Unfriendly")
ratings.Add("LuaKing")
ratings.Add("Winner")
ratings.Add("Thanks")
ratings.Add("Funny")

ratings.Rates:Load()

local ctcp_tbl = {
	VERSION = function(sender, channel, message)
		sendNotice(sender, "\1VERSION ITSBOT v1.5 (Lua) by ITSBTH\1")
	end,
	TIME = function(sender, channel, message)
		sendNotice(sender, "\TIME ".. os.time() .."\1")
	end,
}

local function ctcp(sender, channel, message)
	local act = message:sub(1, (message:find(' ') or 0) - 1)
	print("Action: " .. act)
	if ctcp_tbl[act] then
		ctcp_tbl[act](sender, channel, message)
	end
end

hook.Add(ctcp, 'OnCtcp', 'ONCTCPMG')

local function rename(sender, channel, reason)
	if sender == "ITSBOT" then
		doRaw("NICK ITSBOT")
	end
end

hook.Add(rename, 'OnQuit', 'RenameSelf')

local function reload(sender, channel, arg)
	dofile 'simple.lua'
end

command.Add("reload", reload, "Reloads the script", 5)
