--[[
local socket = require 'socket'

local s = socket.connect("irc.gamesurge.net", 6667)

s:send("USER LuaBot foo bar :Foo Bar\r\n")
s:send("NICK ITSBOT\r\n")
]]

local messagestack = messagestack or {}

local lastmessage = 0

local lastPing = os.time()
local pingSent = false

users = users or {}
status = status or {}
local statTable = {o = "@", v = "+"}

local logFile = io.open("logs/raw.log", "a+")

function sendMessage(chan, msg)
	--s:send('PRIVMSG ' .. chan .. ' :' .. msg .. '\r\n')
	if not (chan and msg) or (chan == '' or msg == '') or (type(chan) ~= 'string' or type(msg) ~= 'string') then return end
	table.insert(messagestack, {chan = chan, msg = msg})
end

function sendCTCPMessage(chan, msg)
	s:send('PRIVMSG ' .. chan .. ' :\01' .. msg .. '\01\r\n')
end

function sendNotice(chan, msg)
	s:send('NOTICE ' .. chan .. ' :' .. msg .. '\r\n')
end

function sendCTCPNotice(chan, msg)
	s:send('NOTICE ' .. chan .. ' :\01' .. msg .. '\01\r\n')
end

function joinChannel(chan)
	s:send("JOIN " .. chan .. "\r\n")
end

function partChannel(chan)
	s:send("PART " .. chan .. "\r\n")
end

function doRaw(raw)
	s:send(raw .. "\r\n")
end

function quitServer(message)
	s:send("QUIT :" .. message .. "\r\n")
	onSelfQuit()
	socket.sleep(2)
	os.exit()
end

dofile('init.lua')

function loop(s)
	local line, err = s:receive('*l')
	if line then
        logFile:write(line .. "\n")
		lastPing = os.time()
		if line:sub(1, 1) == ':' then
			local n = line:find(' ')
			local prefix = line:sub(2, n - 1)
			local rest = line:sub(n + 1)
			n = prefix:find('!')
			local nick, host
			if n then
				nick = prefix:sub(1, n - 1)
				host = prefix:sub(n + 1)
			else
				nick = prefix
			end
			n = rest:find(' ')
			local com = rest:sub(1, n - 1)
			if com == 'PRIVMSG' then
				local tmp = rest:sub(n + 1)
				n = tmp:find(' ')
				local chan = tmp:sub(1, n - 1)
				local msg = tmp:sub(n + 2)
				onMessage(chan, nick, nil, host, msg)
			elseif com == 'NOTICE' then
				local tmp = rest:sub(n + 1)
				n = tmp:find(' ')
				local chan = tmp:sub(1, n - 1)
				local msg = tmp:sub(n + 2)
				onNotice(chan, nick, nil, host, msg)
			elseif com == 'PONG' then
				local tmp = rest:sub(n + 1)
				n = tmp:find(' ')
				local via = tmp:sub(1, n - 1)
				local to = tmp:sub(n + 2)
				pingSent = false
				lastPing = os.time()
			elseif com == 'JOIN' then
			
			elseif com == 'PART' then
			
			elseif com == 'QUIT' then
				local tmp = rest:sub(n + 1)
				onQuit(tmp)
			elseif com == '433' then
				s:send("NICK ITSBOT_Lua\r\n")
			elseif com == '353' then
				local tmp = rest:sub(n + 1)
				local n = tmp:find('=') or tmp:find('@')
				local colon = tmp:find(':')
				local chan = tmp:sub(n + 2, colon - 2)
				local list = tmp:sub(colon + 1)
				users[chan] = explode(' ', list)
				generateStatus()
			elseif com == 'MODE' then
				local tmp = rest:sub(n + 1)
				n = tmp:find(' ')
				local chan = tmp:sub(1, n - 1)
				local r2 = tmp:sub(n + 1)
				local p = r2:find(' ')
				if p then
					local mode = r2:sub(1, p - 1)
					local user = r2:sub(p + 1)
					if mode:sub(2, 2) == "o" or mode:sub(2, 2) == "v" then
						if mode:sub(1, 1) == "+" then
							status[chan][user] = statTable[mode:sub(2, 2)]
						else
							status[chan][user] = " "
						end
					end
				end
			end
		elseif line:sub(1, 4) == 'PING' then
			s:send('PONG ' .. line:sub(6) .. "\r\n")
		elseif line:sub(1, 4) == 'PONG' then
			pingSent = false
			lastPing = os.time()
		end
		if line:find('END') then
			onConnect()
		end
		print(line)
	elseif err ~= "timeout" then
		quitServer("Socket error")
	else
		if #messagestack > 0 and lastmessage + 1 < os.time() then
			local msg = table.remove(messagestack, 1)
			s:send('PRIVMSG ' .. msg.chan .. ' :' .. msg.msg .. '\r\n')
		end
		socket.sleep(1)
	end
	if lastPing + 300 < os.time() then
		quitServer("Ping timeout")
	end
	return loop(s)
end

function generateStatus()
	for k,v in pairs(users) do
		status[k] = {}
		for n,u in pairs(v) do
			local m = u:sub(1, 1)
			if m == "@" or m == "+" then
				status[k][u:sub(2)] = m
			else
				status[k][u] = " "
			end
		end
	end
end
