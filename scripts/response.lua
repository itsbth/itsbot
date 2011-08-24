response = {}

response.Data = data:New("response")

function response.Add(sender, channel, arg)
	local msg, kw = splitArgs(arg)
	response.Data:Add(kw[1]:lower(), {kw = kw[1], msg = msg})
end

command.Add("addresponse", response.Add, "Adds a response", command.ALL, 2)

function response.Remove(sender, channel, arg)
	response.Data:Remove(arg:lower())
end

command.Add("removeresponse", response.Remove, "Removes a response", command.ALL, 2)

function response.Listen(sender, channel, arg)
	if sender == "ITSBOT" or not arg then return end
	for k,v in ipairs(response.Data.Data) do
		if v.name then
			if arg:lower():find(v.name) then
				sendMessage(channel, v.msg)
			end
		end
	end
end

hook.Add(response.Listen, hook.MSG)
