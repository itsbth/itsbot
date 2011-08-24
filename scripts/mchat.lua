local bot = require 'markov'
local iconv = require 'iconv'

local conv = assert(iconv.new("utf-8//IGNORE", "utf-8"))

local enabled = {["#testobot"] = true, ["#wiremod"] = false}
local respond = {}
local gag = {}
local gagger = {}
local talkers = {}
local assholes = {}
local prob = 0.2

local GAG_TIME = 300
local GAG_LOCK = 360
local GAG_ACTI = 300

local function chook(sender, channel, arg)
	arg = conv:iconv(arg)
	if arg:lower():find("itsbot") and not respond[channel] then
		sendMessage(channel, bot.generateSentenceFromString(arg))
		return
	end
	bot.add(arg)
	if enabled[channel] and math.random() < prob then
		if not gag[channel] or (gag[channel] and gag[channel] < os.clock()) then
			sendMessage(channel, bot.generateSentenceFromString(arg))
		end
	end
	talkers[channel] = talkers[channel] or {}
	talkers[channel][sender] = os.clock()
end

hook.Add(chook, hook.MSG, 'chatHool!')

local function quit(sender, channel, arg)
	bot.close()
end

hook.Add(quit, 'SelfQuit', 'mchatSQ')

local function toggle(sender, channel, arg)
	channel = arg:len() > 0 and arg or channel
	enabled[channel] = not enabled[channel]
	if enabled[channel] then
		sendMessage(channel, "Random chatter enabled")
		sendMessage(channel, "You can get me to shut up by saying %stfu")
	else
		sendMessage(channel, "Random chatter disabled")
	end
end

command.Add('togglechat', toggle, "Toggle random chat", command.MSG, 5)

local function toggle(sender, channel, arg)
	channel = arg:len() > 0 and arg or channel
	respond[channel] = not respond[channel]
end

command.Add('toggleresponse', toggle, "Toggle responding to nick", command.MSG, 5)

local function setprob(sender, channel, arg)
	if not tonumber(arg) then
		sendMessage(sender, arg .. " is not a number!")
		return
	end
	prob = tonumber(arg)
	print("Chat probability set to " .. prob)
end

command.Add('setprob', setprob, 'N/A', command.MSG, 5)

local function stfu(sender, channel, arg)
	if talkers[channel] and talkers[channel][sender] and talkers[channel][sender] + GAG_ACTI > os.clock() then
		if not gagger[sender] or gagger[sender] < os.clock() then
			local t = os.clock()
			local l = GAG_TIME
			if arg and arg ~= "" then
				l = tonumber(arg)
				if not l then
					sendNotice(sender, '"' ..  arg .. '" is not a number.')
					return
				end
				if status[channel] and status[channel][sender] and status[channel][sender]:sub(1, 1) == "@" then
					if l > 30 * 60 then
						sendNotice(sender, "I defy your authority!")
						return
					end
				elseif status[channel][sender] and status[channel][sender]:sub(1, 1) == "+" then
					if l > 10 * 60 then
						sendNotice(sender, "Just because you're voiced doesn't mean you can shut me up for this long.")
						return
					end
				else
					if assholes[sender] and assholes[sender] > os.clock() then
						sendMessage(channel, "!k " .. sender)
						return
					else
						sendMessage(channel, "Who are you to tell me how long I should shut up?")
						assholes[sender] = os.clock() + 10
						return
					end
				end
			else
			
			end
			if gag[channel] and gag[channel] > t then
				gag[channel] = gag[channel] + l
			else
				gag[channel] = t + l
			end
			gagger[sender] = t + l * 1.5
			sendMessage(channel, ("OK, I'll shut up for %d seconds, dickhead."):format(gag[channel] - t))
		else
			sendNotice(sender, "You've already told me to shut up, asshole!")
		end
	else
		sendNotice(sender, "I won't listen to you!")
	end
end
command.Add('stfu', stfu, "Shut the fuck up yourself!", command.MSG)

function mcGTalkers()
	return talkers
end
local function stats(sender, channel, arg)
	local words, relations = bot.getStats()
	local queries = bot.getNumQueries()
	sendMessage(channel, ("Database contains %d words and %d relations. %d queries this session."):format(words, relations, queries))
end
command.Add('cstats', stats, "Various statistics about the chat bot", command.MSG)
