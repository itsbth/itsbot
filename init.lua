local files = {
	"file.lua",
	"util.lua",
	"data.lua",
	"hook.lua",
	"command.lua",
	"admin.lua",
	"config.lua"
}

table.foreach(files, function(_, f)
	local s, err = pcall(dofile, f)
	if not s then
		print(string.format("There was an error running file %q: %q", f, err))
	end
end)

function onMessage(channel, sender, login, hostname, message)
	if not channel:find('#') then return onPrivateMessage(sender, login, hostname, message) end
	if message:sub(1, 1) == "\1" and message:sub(-1, -1) == "\1" then return onCtcp(channel, sender, login, hostname, message:sub(2, -2)) end
	if hook.Call('PreMessage', sender, channel, message) ~= true then
		hook.Call(hook.MSG, sender, channel, message)
	end
end

function onNotice(channel, sender, login, hostname, message)
	if message:sub(1, 1) == "\1" and message:sub(-1, -1) == "\1" then return onNoticeCtcp(channel, sender, login, hostname, message:sub(2, -2)) end
end

function onPrivateMessage(sender, login, hostname, message)
	if message:sub(1, 1) == "\1" and message:sub(-1, -1) == "\1" then return onCtcp(sender, sender, login, hostname, message:sub(2, -2)) end
	if hook.Call('PrePrivateMessage', sender, channel, message) ~= true then
		hook.Call(hook.PM, sender, sender, message)
	end
end

function onCtcp(channel, sender, login, hostname, message)
	if hook.Call('PreCtcp', sender, channel, message) ~= true then
		hook.Call('OnCtcp', sender, sender, message)
	end
end

function onNoticeCtcp(channel, sender, login, hostname, message)
	if hook.Call('PreNoticeCtcp', sender, channel, message) ~= true then
		hook.Call('OnNoticeCtcp', sender, sender, message)
	end
end

function onJoin(channel, sender, login, hostname)
	hook.Call(hook.JOIN, sender, channel, sender)
end

function onPart(channel, sender, login, hostname)
	hook.Call(hook.PART, sender, channel, sender)
end

function onConnect()
	hook.Call(hook.CONNECT)
end

function onQuit(nick, login, hostname, reason)
	hook.Call(hook.QUIT, nick, nick, reason)
end

function onSelfQuit()
	hook.Call('SelfQuit')
end
