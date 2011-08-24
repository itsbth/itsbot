response = {}

response.Data = data:New("response")

function response.Add(sender, channel, arg)
	local msg, kw = splitArgs(arg)
	response.Data:Add(kw[1], {"kw" = kw[1], "msg" = msg})
end

function response.Remove(sender, channel, arg)
	response.Data:Remove(arg)
end

function response.Listen(sender, channel, arg)
	if sender == "ITSBOT" then return end
	for k,v in ipairs(response.Data.Data) do
		if arg:find(k) then
			sendMessage(channel, v.msg)
		end
	end
end

hook.Add(response.Listen, hook.MSG)
