function test(tab)
	for k,v in pairs(tab) do
		
	end
end

function format(val, key)
	key = key or false
	if type(val) == "number" then
		return tostring(val)
	elseif type(val) == "string" then
		if key then return val end
		return '"' .. val .. '"'
	elseif type(val) == "table" then
		local out = "{ "
		for k,v in pairs(val) do
			out = out .. format(k, true) .. " = " .. format(v) .. ", "
		end
		out = out:sub(0, #out - 2)
		out = out .. " }"
		return out
	end
	return tostring(nil)
end
