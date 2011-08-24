local function rollDice(sender, channel, arg)
	local tot = tonumber(arg)
	if math.random(1, 6) == tot then
		casino.modifyBalance(casino.users[sender], 20)
		sendMessage(channel, "Congratulations! You guessed right and won $20!")
	else
		casino.modifyBalance(casino.users[sender], -10)
		sendMessage(channel, "Sorry. You guessed wrong and lost $10.")
	end
end

command.Add("dice", rollDice)