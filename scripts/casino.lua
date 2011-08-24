-- Casino script
local sql = require 'luasql.sqlite3'

local env = assert(sql.sqlite3())
local con = assert(env:connect('data/casino.db'))
-- Setup

local SETUP_SQL = [[
CREATE TABLE users(
	id INTEGER PRIMARY KEY,
	name STRING NOT NULL,
	pass STRING NOT NULL,
	balance INTEGER NOT NULL
)
]]

local function escapeString(str)
	return str:gsub("'", "''")
end

local function sqlQueryOneValue(query, ...)
	local res, err = sqlMagicQuery(query, ...)
	assert(res, err)
	local val = res:fetch()
	res:close()
	return val
end

function sqlMagicQuery(sql, ...)
	local i = 1
	local q = sql:gsub("%%(.)", function(str) local inp = arg[i] if str == 'q' then inp = escapeString(inp) end i = i + 1 return ('%' .. str):format(inp) end)
	return con:execute(q)
end

-- Data

local RANDPASS = {
	"cake",
	"pie",
	"rossthefag",
	"cookies",
	"spam",
	"sqrt",
	"zen",
	"wire",
	"gmod",
	"dead",
	"broken",
	"dumb",
	"king",
	"runescape",
	"wow",
	"thisisalongpasswordjusttoirritateyouyouarefuckedhahaha",
	"password",
	"1234",
	"password1",
	"username",
	"address",
	"telephonenumber",
}

-- Code

casino = {}
casino.games = {}
casino.tables = {}
casino.actions = {}
casino.users = {}

function casino.getBalance(user)
	return sqlQueryOneValue("SELECT balance FROM users WHERE id = %d;", user)
end

function casino.setBalance(user, balance)
	sqlMagicQuery("UPDATE users SET balance = %d WHERE id = %d", user, balance)
end

function casino.modifyBalance(user, delta)
	sqlMagicQuery("UPDATE users SET balance = balance + %d WHERE id = %d", user, delta)
end


function casino.registerGame(name, constructor)
	casino.games[name] = constructor
end

function casino.actions.startGame(sender, channel, arg)
	local _, e, n = arg:find "([^ ]+) ?"
	if casino.games[n] then
		if not casino.tables[channel] then
			casino.tables[channel] = casino.tables, casino.games[n](sender, channel, arg:sub(e + 1))
		else
			sendMessage(channel, "There is already a game in progress")
		end
	else
		sendMessage(channel, "No such game")
	end
end

function casino.actions.createGame(sender, channel, arg)
	local _, e, n = arg:find "([^ ]+) ?"
	local chan = "ic" .. n .. math.random(1, 999)
	while casino.tables[chan] do
		chan = "ic" .. n .. math.random(1, 999)
	end
	joinChannel(chan)
	casino.tables[chan] = casino.games[n](sender, chan, arg:sub(e + 1))
	sendMessage(channel, ("Game created in %s"):format(chan))
end

function casino.actions.joinGame(sender, channel, arg)
	if casino.tables[channel] then
		casino.tables[channel]:playerJoin(sender)
	else
		sendMessage(channel, "No game in progress")
	end
end

function casino.actions.registerUser(sender, channel, arg)
	local pass = RANDPASS[math.random(1, #RANDPASS)]
	local sql = ("INSERT INTO users (name, pass, balance) VALUES ('%s', '%s', 100);"):format(escapeString(sender), escapeString(pass))
	assert(con:execute(sql))
	sendNotice(sender, ("An account have been created with the password '%s'"):format(pass))
end

function casino.actions.login(sender, channel, arg)
	if not casino.users[sender] then
		local pass = sqlQueryOneValue("SELECT pass FROM users WHERE name = %q;", sender)
		if pass then
			print("pass=", pass, "arg=", arg)
			if pass == arg then
				sendNotice(sender, "You are now logged in")
				casino.users[sender] = sqlQueryOneValue("SELECT id FROM users WHERE name = %q;", sender)
			else
				sendNotice(sender, "Wrong username or password")
			end
		else
			sendNotice(sender, "Wrong username or password")
		end
	else
		sendNotice(sender, "You are already logged in")
	end
end

function casino.actions.help(sender, channel, arg)
	sendMessage(channel, "Help not yet available. Ask ITSBTH")
end

function casino.actions.balance(sender, channel, arg)
	if casino.users[sender] then
		sendNotice(sender, "You have $" .. casino.getBalance(casino.users[sender]))
	end
end

function casino.command(sender, channel, arg)
	local _, e, n = arg:find "([^ ]+) ?"
	if casino.actions[n] then
		casino.actions[n](sender, channel, arg:sub(e + 1))
	else
		sendMessage(channel, "No such action")
	end
end

command.Add("casino", casino.command)

function casino.preChatHook(sender, channel, message)

end
