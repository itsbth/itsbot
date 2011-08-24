hook = {}

hook.Hooks = {}

hook.Count = 0

-- Deprecated constants
hook.ALL = 'All'
hook.MSG = 'OnMessage'
hook.PM = 'OnPrivateMessage'
hook.JOIN = 'OnJoin'
hook.PART = 'OnPart'
hook.CONNECT = 'OnConnect'
hook.QUIT = 'OnQuit'

function hook.Call(typ, ...)
	print(string.format('Calling hook %q', typ))
	if not hook.Hooks[typ] then return end
	for k,v in pairs(hook.Hooks[typ]) do
		local s, err = pcall(v.func, ...)
		if not s then
			print(string.format('Error running hook %q: %q', k, err))
			sendMessage("ITSBTH", string.format('Error running hook %q: %s', k, err:gsub("\n", " ")))
		elseif err ~= nil then
			return err
		end
	end
	return nil
end

function hook.Add(func, typ, name)
	name = name or "hook"..hook.Count
	hook.Hooks[typ] = hook.Hooks[typ] or {}
	if not table.haskey(hook.Hooks[typ], name) then hook.Count = hook.Count + 1 end
	hook.Hooks[typ][name] = {func = func, type = typ}
end

function hook.Remove(name)
	table.remove(hook.Hooks, name)
end
