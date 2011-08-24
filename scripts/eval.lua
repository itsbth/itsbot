local function pack(...)
	return arg
end

-- Buffered print
local msgbuf
local function printb(...)
	local t = {}
	for i = 1, select("#", ...) do
		t[#t + 1] = tostring(select(i, ...))
	end
	t = table.concat(t, "\t")
	for s in t:gmatch("([^\r\n]+)") do
		table.insert(msgbuf, s)
	end
end

local function loop(func)
	local run = true
	local ret = nil
	local max = os.time() + 2
	while run do
		run, ret = func()
		if max < os.time() then
			error("Out of time")
		end
	end
	return true, ret
end

local function tcopy(tab)
	local out = {}
	for k,v in pairs(tab) do
		out[k] = v
	end
	return out
end

local function wrap(f)
	return function(...)
		for k, v in ipairs(arg) do
			if type(v) == "string" or type(v) == "table" then
				if #v > 128 then
					error("too large " .. type(v))
				end
			end
		end
		return f(unpack(arg))
	end
end

local emath, estring, etable, eos = tcopy(math), tcopy(string), tcopy(table), {}

for k, v in pairs(estring) do
	if type(v) == "function" then
		estring[k] = wrap(v)
	end
end

eos.clock, eos.time, eos.date, eos.difftime = os.clock, os.time, os.date, os.difftime

-- make environment
local env = {
	math = emath,
	string = estring,
	table = etable,
	os = eos,
	type = type,
	loop = loop,
	print = printb,
	tostring = tostring,
	unpack = unpack,
	pairs = pairs,
	_VERSION = _VERSION
}
env._G = env

-- run code under environment
local function run(untrusted_code)
	local untrusted_function, message = loadstring(untrusted_code)
	if not untrusted_function then return nil, message end
	setfenv(untrusted_function, env)
	local r = pack(pcall(untrusted_function))
	return unpack(r)
end

local function eval(sender, channel, arg)
	if arg:find 'while' then
		sendMessage(channel, "Error: while blocked, use loop(function() ...; return shouldRunAgain; end)")
		return
	end
	if arg:find "function (.-)\(\)return(.-)\(\)(.-)end(.-)\(\)" and false then
		if status[channel]["ITSBOT"] == "@" then
			sendMessage(channel, "!kb " .. sender .. " No you don't")
		else
			sendMessage(channel, "Don't even think about it")
		end
		return
	end
	msgbuf = {}
	local r = {run(arg)}
	if r[1] then
		local ser = {}
		for i = 2, #r do
			ser[#ser + 1] = serialize(r[i])
		end
		ser = table.concat(ser, ", ")
		if #ser > 500 then
			sendMessage(channel, "Error: Result too long (" .. #ser ..")")
		elseif #ser == 0 then
			sendMessage(channel, "No result")
		else
			sendMessage(channel, "Result: " .. ser)
		end
		if #msgbuf > 0 then
			if #msgbuf < 4 then
				sendMessage(channel, "-- OUTPUT --")
				for k,v in ipairs(msgbuf) do
					sendMessage(channel, "> " .. v)
				end
			else
				sendMessage(channel, "ERROR: More than three lines printed")
			end
		end
	else
		sendMessage(channel, "Error: " .. r[2])
	end
end

command.Add('eval', eval, 'Evaluate a lua snippet', command.MSG)

function evalGetEnv()
	return env
end
