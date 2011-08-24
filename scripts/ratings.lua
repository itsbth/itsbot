ratings = {}

ratings.Rates = data:New("ratings")

ratings.Types = {}

ratings.Time = {}

function ratings.Rate(sender, channel, arg)
	local t = os.time()
	if ratings.Time[sender] == nil then ratings.Time[sender] = 0 end
	if (t - ratings.Time[sender]) < 15 then return sendMessage(sender, "You can't rate so often! Time left: " .. 15 - (t - ratings.Time[sender]) .." seconds") end
	local args = explode(" ", arg)
	--if not (arg[1] or arg[2]) then return sendMessage(sender, "Invalid parameters") end
	local rate = ratings.Rates:Get(args[1]) or ratings.Rates:Add(args[1])
	if not ratings.IsValid(args[2]) then return sendMessage(sender, "Invalid type!") end
	if args[1] == sender then return sendMessage(sender, "You can't rate yourself!") end
	ratings.Time[sender] = t
	for _,v in ipairs(ratings.Types) do
		if v:lower() == args[2]:lower() then
			args[2] = v
			break
		end
	end
	rate[args[2]] = rate[args[2]] or 0
	rate[args[2]] = rate[args[2]] + 1
	sendMessage(channel, sender .. " rated " .. args[1] .. " " .. args[2] .. ". Total = " .. rate[args[2]])
	response.Data:Save()
end

command.Add("rate", ratings.Rate, "Rate a person. Usage: rate person rating")

function ratings.GetRatings(sender, channel, arg)
	local rate = ratings.Rates:Get(arg)
	if not rate then
		sendMessage(channel, arg .. " hasn't received any ratings")
	end
	local out = ""
	for k,v in pairs(rate) do
		if k ~= "name" then
			out = out .. " " .. k .. " " .. v .. " |"
		end
	end
	sendMessage(channel, arg .. " ratings:" .. out:sub(0, #out - 2))
end

command.Add("getratings", ratings.GetRatings, "Get a user ratings. Usage: getratings person")

function ratings.IsValid(typ)
	for k,v in ipairs(ratings.Types) do
		if v:lower() == typ:lower() then return true end
	end
	return false
end

function ratings.Add(name)
	if ratings.IsValid(name) then return end
	table.insert(ratings.Types, name)
end

function ratings.List(sender, channel, arg)
	local out = ""
	for k,v in pairs(ratings.Types) do
		out = out .. v .. " "
	end
	sendMessage(channel, out)
end

command.Add("listratings", ratings.List, "List available ratings")
