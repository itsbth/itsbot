command = {}

command.Commands = {}

command.ALL = 1
command.MSG = 2
command.PM = 3

command.Sign = nil

function command.Call(com, arg, sender, channel)
	if command.Commands[com] then
		if not admin.HasAccess(sender, command.Commands[com].access) then
			sendNotice(sender, "You do not have access to this command!")
			return
		end
		local s, err = pcall(command.Commands[com].func, sender, channel, arg)
		if not s then
			print(string.format('Error running command %q:\n%s', com, err))
			sendMessage("ITSBTH", string.format('Error running command %q: %s', com, err:gsub("\n", " ")))
		end
	else
		print(string.format('No command %q', com))
	end
end

function command.Add(com, func, desc, _, access)
	access = access or 0
	desc = desc or "No description"
	command.Commands[com] = {func = func, access = access, desc = desc}
end

function command.Remove(com)
	table.remove(command.Commands, com)
end

function command.SetSign(sign)
	command.Sign = sign
end

function command.GetSign()
	return command.Sign
end

function command.SplitCommand(str)
	local sp = explode(" ", str)
	local com = string.sub(sp[1], string.len(command.Sign) + 1)
	table.remove(sp, 1)
	return com, table.concat(sp, " ")
end

function command.IsCommand(str)
	return string.sub(str, 0, string.len(command.Sign)) == command.Sign
end

function command.List(sender, channel, arg)
	for k,v in pairs(command.Commands) do
		if admin.HasAccess(sender, v.access) then
			sendMessage(sender, k .. ": " .. v.desc .. " - ".. v.access)
		end
	end
end

command.Add("commands", command.List)

function command.Help(sender, channel, arg)
	for k,v in pairs(command.Commands) do
		if k == arg and admin.HasAccess(sender, v.access) then
			sendMessage(channel, k .. ": " .. v.desc .. " - ".. v.access)
			return
		end
	end
end

command.Add("help", command.Help)

function command.Hook(sender, channel, message)
	if command.IsCommand(message) then
		local com, arg = command.SplitCommand(message)
		command.Call(com, arg, sender, channel)
		return true -- We have handled this message, don't call other hooks
	end
	return nil
end

hook.Add(command.Hook, 'PreMessage', 'command.Hook')
hook.Add(command.Hook, 'PrePrivateMessage', 'command.Hook')
