function eval(str)
	local n = 0
	for op,num in string.gmatch(str, '([+-\\*\\/])(%d+)') do
		if op == '+' then
			n = n + num
		elseif op == '-' then
			n = n - num
		elseif op == '*' then
			n = n * num
		elseif op == '/' then
			n = n / num
		end
		print(op .. ' : ' .. num .. ' = ' .. n)
	end
	return n
end
