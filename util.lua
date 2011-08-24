function table.haskey(table, key)
	for k,v in pairs(table) do
		if k == key then return true end
	end
	return false
end

function table.includes(table, value)
	for k,v in pairs(table) do
		if v == value then return true end
	end
	return false
end

function table.count(t, value)
	local c = 0
	for k,v in pairs(t) do
		if v == value then
			c = c + 1
		end
	end
	return c
end

function table.unique(t)
	local out = {}
	for k,v in pairs(t) do
		if not table.includes(out, v) then
			out[k] = v
		end
	end
	return out
end

--\[[
function explode(div,str) -- abuse to: http://richard.warburton.it
	local pos,arr = 0,{}
	for st,sp in function() return string.find(str,div,pos,true) end do -- for each divider found
		table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
		pos = sp + 1 -- Jump past current divider
	end
	table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
	return arr
end
--]]

function splitArgs(arg, n)
	n = n or 1
	local res = explode(" ", arg)
	local out = {}
	for i = 1,n do
		table.insert(out, res[i])
		table.remove(res, i)
	end
	return table.concat(res, " "), out
end

--[[
   Author: Julio Manuel Fernandez-Diaz
   Date:   January 12, 2007
   (For Lua 5.1)
   
   Modified slightly by RiciLake to avoid the unnecessary table traversal in tablecount()

   Formats tables with cycles recursively to any depth.
   The output is returned as a string.
   References to other tables are shown as values.
   Self references are indicated.

   The string returned is "Lua code", which can be procesed
   (in the case in which indent is composed by spaces or "--").
   Userdata and function keys and values are shown as strings,
   which logically are exactly not equivalent to the original code.

   This routine can serve for pretty formating tables with
   proper indentations, apart from printing them:

      print(table.show(t, "t"))   -- a typical use
   
   Heavily based on "Saving tables with cycles", PIL2, p. 113.

   Arguments:
      t is the table.
      name is the name of the table (optional)
      indent is a first indentation (optional).
--]]
function table.show(t, name, indent)
   local cart     -- a container
   local autoref  -- for self references

   --[[ counts the number of elements in a table
   local function tablecount(t)
      local n = 0
      for _, _ in pairs(t) do n = n+1 end
      return n
   end
   ]]
   -- (RiciLake) returns true if the table is empty
   local function isemptytable(t) return next(t) == nil end

   local function basicSerialize (o)
      local so = tostring(o)
      if type(o) == "function" then
         local info = debug.getinfo(o, "S")
         -- info.name is nil because o is not a calling level
         if info.what == "C" then
            return string.format("%q", so .. ", C function")
         else 
            -- the information is defined through lines
            return string.format("%q", so .. ", defined in (" ..
                info.linedefined .. "-" .. info.lastlinedefined ..
                ")" .. info.source)
         end
      elseif type(o) == "number" then
         return so
      else
         return string.format("%q", so)
      end
   end

   local function addtocart (value, name, indent, saved, field)
      indent = indent or ""
      saved = saved or {}
      field = field or name

      cart = cart .. indent .. field

      if type(value) ~= "table" then
         cart = cart .. " = " .. basicSerialize(value) .. ";\n"
      else
         if saved[value] then
            cart = cart .. " = {}; -- " .. saved[value] 
                        .. " (self reference)\n"
            autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
         else
            saved[value] = name
            --if tablecount(value) == 0 then
            if isemptytable(value) then
               cart = cart .. " = {};\n"
            else
               cart = cart .. " = {\n"
               for k, v in pairs(value) do
                  k = basicSerialize(k)
                  local fname = string.format("%s[%s]", name, k)
                  field = string.format("[%s]", k)
                  -- three spaces between levels
                  addtocart(v, fname, indent .. "   ", saved, field)
               end
               cart = cart .. indent .. "};\n"
            end
         end
      end
   end

   name = name or "__unnamed__"
   if type(t) ~= "table" then
      return name .. " = " .. basicSerialize(t)
   end
   cart, autoref = "", ""
   addtocart(t, name, indent)
   return cart .. autoref
end

function print_r(tab)
	print(table.show(tab))
end

function pad(str, n, p)
	return p:rep(n - str:len()) .. str
end

function serialize(var)
	if type(var) == 'table' then
		local out = '{'
		local f = false
		for k,v in pairs(var) do
			if f then
				out = out ..  ', '
			end
			if v == var then
				out = out .. '[' .. serialize(k) .. ']' .. ' = ' .. 'nil --[[(self reference)]]'
			else
				out = out .. '[' .. serialize(k) .. ']' .. ' = ' .. serialize(v)
			end
			f = true
		end
		return out ..  '}'
	elseif type(var) == 'string' then
		return ('%q'):format(var):gsub("\n", "n") -- %q is broken...
	elseif type(var) == 'number' then
		return tostring(var)
	elseif type(var) == 'boolean' then
		if var then
			return 'true'
		else
			return 'false'
		end
	elseif type(var) == 'function' then
		local s, r = pcall(function()
			return 'loadstring("' .. string.dump(var):gsub('([^A-Za-z0-9])', function(p) return '\\' .. pad(tostring(p:byte()), 3, '0') end) .. '")'
		end)
		return s and r or 'function() end'
	elseif type(var) == 'nil' then
		return 'nil'
	end
end

function pack(...)
	return arg
end
