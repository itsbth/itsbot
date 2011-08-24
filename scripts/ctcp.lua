local ctcp = {}

function ctcp.VERSION(user, message)
	sendCTCPNotice(user, "VERSION LuaBot v1.5 by ITSBTH")
end

local function onCtcp(user, message)
	if ctcp[message] then
		ctcp[message](user, message)
	end
end

hook.Add(onCtcp, 'onCtcp', "CTCPHandler")
