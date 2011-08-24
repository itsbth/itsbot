listen = {}

listen.Active = {}

function listen.Add(sender, channel, arg)
	if table.haskey(listen.Active, arg) then return end
	listen.Active[arg] = channel
end

command.Add("listen", listen.Add, "Start listening to a channel", command.MSG, 5)

function listen.Remove(sender, channel, arg)
	listen.Active[arg] = nil
end

command.Add("stoplisten", listen.Remove, "Stop listening to a channel", command.MSG, 5)

function listen.Listen(sender, channel, arg)
	for k,v in pairs(listen.Active) do
		if k == channel then
			sendMessage(v, "<"..sender..":"..channel.."> "..arg)
		end
	end
end

hook.Add(listen.Listen, hook.MSG, "listen.Listen")
