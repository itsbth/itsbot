local words = words or {}
local childs = childs or {}
local enabled = {["#testobot"] = true}
local prob = 0.2
local maxlen = 8

if _file.Exists('data/chat.lua') then
	words,childs = dofile('data/chat.lua')
end

function parsestring(str)
	local arr = {}
	for w in str:gmatch("[%a']+") do
		arr[#arr+1] = w
	end
	for i = 1,#arr do
		if not table.includes(words, arr[i]) then
			words[#words+1] = arr[i]
		end
		if arr[i+1] then
			if not childs[arr[i]] then childs[arr[i]] = {} end
			if not table.includes(childs[arr[i]], arr[i+1]) then
				table.insert(childs[arr[i]], arr[i+1])
			end
		end
	end
end

local function clean()
	words = table.unique(words)
	for k,v in pairs(childs) do
		childs[k] = table.unique(v)
	end
end

command.Add('chatclean', clean)

function speak()
	local i = math.random(#words)
	local out = words[i]
	local lw = out
	local n = 0
	while lw and childs[lw] and #childs[lw] > 0 and n < maxlen do
		local r = math.random(#childs[lw])
		lw = childs[lw][r]
		out = out .. " " .. lw
		n = n + 1
	end
	return out
end

function large(str)
	for sentence in str:gmatch("[^.]+") do
		parsestring(sentence)
	end
end

local function chook(sender, channel, arg)
	large(arg)
	if enabled[channel] and math.random() < prob then
		sendMessage(channel, speak())
	end
end

hook.Add(chook, hook.MSG, 'chatHool!')

local function toggle(sender, channel, arg)
	enabled[channel] = not enabled[channel]
	if enabled[channel] then
		sendMessage(channel, 'Random chatter enabled')
	else
		sendMessage(channel, 'Random chatter disabled')
	end
end

command.Add('togglechat', toggle, 'Toggle random chat', command.MSG, 5)

local function setprob(sender, channel, arg)
	if not tonumber(arg) then
		sendMessage(sender, arg .. ' is not a number!')
		return
	end
	prob = tonumber(arg)
	print('Chat probability set to ' .. prob)
end

command.Add('setprob', setprob, 'N/A', command.MSG, 5)

local function csave(sender, channel, arg)
	_file.Write('data/chat.lua', 'return ' .. serialize(words) .. ',' .. serialize(childs))
end

command.Add('csave', csave, 'N/A', command.MSG, 1)