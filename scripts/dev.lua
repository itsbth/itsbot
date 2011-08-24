function eval(sender, channel, arg)
	local res,s = nil,nil
	do
		local env = {dostring = dostring, pcall = pcall, loadstring = loadstring, smsg = sendMessage, gt = _G}
		local f, res = loadstring(arg)
		setfenv(1, env)
		if f then
			s,res = pcall(f)
		end
	end
	gt.setfenv(1, gt)
	if s then
		sendMessage(channel, 'Result: ' .. tostring(res))
	else
		sendMessage(channel, 'Error: ' .. tostring(res))
	end
end

command.Add("eval", eval)