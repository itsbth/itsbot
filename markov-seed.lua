require 'markov'

function fsize (file)
	local current = file:seek()      -- get current position
	local size = file:seek("end")    -- get file size
	file:seek("set", current)        -- restore position
	return size
end

function trim (s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

BUFF_SIZE = 128
BAR_LEN = 50

markov.setup()

local file = select(1, ...)
local f = assert(io.open(file, 'r'))

local buffer, pos, size = "", 0, fsize(f)
while pos < size do
	local buff = f:read(BUFF_SIZE) -- lol?
	for i = 0, #buff do
		local char = buff:sub(i, i)
		if char ~= "\n" and char ~= "\r"  then
			if char == "." or char == "!" or char == "?" then
				buffer = trim(buffer)
				if #buffer > 0 then
					-- Process buffer
					markov.addSentence(buffer)
				end
				buffer = ""
			else
				buffer = buffer .. char
			end
		end
	end
	
	pos = math.min(pos + BUFF_SIZE, size)
	local pc = math.floor((pos / size) * BAR_LEN)
	io.write("\r[" .. ("="):rep(pc) .. (" "):rep(BAR_LEN - pc) .. "] " .. pos .. " / " .. size)
end

print()

markov.close()
