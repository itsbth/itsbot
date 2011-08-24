
data = {}

data.Data = {}

data_mt = { __index = data }

function data:New(name)
	return setmetatable({name = name}, data_mt)
end

function data:Add(name, dat)
	dat = dat or {}
	dat.name = name
	table.insert(self.Data, dat)
	return dat
end

function data:Remove(name)
	for k,v in pairs(self.Data) do
		if v.name == name then
			table.remove(self.Data, k)
			return
		end
	end
end

function data:Save()
	local out = ""
	for k,v in pairs(self.Data) do
		for ka,va in pairs(v) do
			out = out .. ka .. "=" .. va .. "|"
		end
		out = out:sub(0, #out - 1) .. "\n"
	end
	_file.Write("data/" .. self.name .. ".data.txt", out)
end

function data:Load()
	if _file.Exists("data/" .. self.name .. ".data.txt") then
		local vars = {}
		local inp = _file.Read("data/" .. self.name .. ".data.txt")
		local lines = explode("\n", inp)
		for k,v in pairs(lines) do
			local o = {}
			local n = explode("|", v)
			for k,v in pairs(n) do
				local n = explode("=", v)
				o[n[1]] = n[2]
			end
			table.insert(vars, o)
		end
		self.Data = vars
	end
end

function data:Get(name)
	for k,v in pairs(self.Data) do
		if v.name == name then
			return v
		end
	end
	return nil
end

function data:Change(name, arg)
	for k,v in pairs(self.Data) do
		if v.name == name then
			v = arg
			v.name = name
		end
	end
end

function Data(name)
	return data:New(name)
end
