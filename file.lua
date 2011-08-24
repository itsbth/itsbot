_file = {}

function _file.Read(fn)
	local f = io.open(fn,"r")
	local r = f:read("*all")
	f:close()
	return r
end

function _file.Write(fn, ...)
	local f = io.open(fn,"w")
	f:write(unpack(arg))
	f:close()
end

function _file.Exists(fn)
	if io.open(fn,"r") then
		return true
	end
	return false
end
