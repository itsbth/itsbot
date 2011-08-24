--local sqlite = require 'luasql.sqlite3'

--local env = sqlite()

--local con = env:connect('data/admin.db')

admin = {}

admin.Admins = {}

function admin.Add(name, level)
	table.insert(admin.Admins, {name = name, level = level})
end

function admin.Remove(name)
	for k,v in pairs(admin.Admins) do
		if v.name == name then
			table.remove(admin.Admins, k)
		end
	end
end

function admin.HasAccess(name, level)
	print(string.format('admin.HasAccess(%q, %d)', name, level))
	for k,v in pairs(admin.Admins) do
		if v.name == name then
			return v.level >= level
		end
	end
	return level == 0
end

function admin.GetAccess(name)
	for k,v in pairs(admin.Admins) do
		if v.name == name then
			return v.level
		end
	end
	return 0
end

function admin.SetAccess(name, level)
	for k,v in pairs(admin.Admins) do
		if v.name == name then
			v.level = level
		end
	end
end

function admin.Load()
	dofile("admins.lua")
	admin.Clean()
end

function admin.Save()
	admin.Clean()
	local out = ""
	for k,v in ipairs(admin.Admins) do
		out = out .. "admin.Add("..serialize(v.name)..", "..serialize(v.level)..")\n"
	end
	-- out = out:gsub("\\", "\\\\")
	_file.Write("admins.lua", out)
end

function admin.Clean()
	for k,v in ipairs(admin.Admins) do
		for ka,va in ipairs(admin.Admins) do
			if va.name == v.name and k ~= ka then
				table.remove(admin.Admins, ka)
			end
		end
	end
end

function admin.List(sender, channel, arg)
	for k,v in ipairs(admin.Admins) do
		sendMessage(sender, v.name .. " - " .. v.level)
	end
end

command.Add("admins", admin.List, "List all admins")
