socket = require 'socket'

server = arg[1] or "irc.gamesurge.net"
port = arg[2] or 6667

local err
s, err = socket.connect(server, port)

if not s then
	print("Unable to connect to " .. server .. " at port " .. port .. ":")
	print(err)
	print("Retrying in one minute")
	io.write("60 seconds")
	for i = 1, 60 do
		socket.sleep(1)
		io.write("\r" .. (60 - i) .. " seconds ")
	end
	print("\nRetrying...")
	return
end

s:settimeout(1, 't')
s:settimeout(1, 'b')

s:send("USER LuaBot foo bar :Foo Bar\r\n")
s:send("NICK ITSBOT\r\n")

--s[#s + 1] = socket.connect("irc.quakenet.org", 6667)

--s[#s]:settimeout(1, 't')
--s[#s]:settimeout(1, 'b')

--s[#s]:send("USER LuaBot foo bar :Foo Bar\r\n")
--s[#s]:send("NICK ITSBOT\r\n")

dofile('simple.lua')

loop(s)