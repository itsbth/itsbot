-- Markov chains chat bot

local assert = assert
local ipairs = ipairs
local tonumber = tonumber
local getmetatable = getmetatable

local print = print

local table = table

local sql = require 'luasql.postgres'

module 'markov'

local env = assert(sql.postgres())
local con = assert(env:connect(unpack(require('conf.lua').markov.db))

local WORD_PATTERN = "([^ .,:;\"()?!]+)"
local SENTENCE_PATTERN = "([^\\.\n?!]+)"

local words = {} -- ID cache
local relations = {} -- Relation cache

local numQueries = 0

function getNumQueries()
	return numQueries
end

local function sqlQuery(query)
	numQueries = numQueries + 1
	return con:execute(query)
end

function setup()
	local res = sqlQuery("SELECT COUNT(id) FROM word WHERE word = '<start>';")
	local row = res:fetch{}
	if row and row[1] and tonumber(row[1]) < 1 then
		local success, err = sqlQuery[[
		INSERT INTO word (word) VALUES ('<start>');
		]]
		assert(success, err)
		local success, err = sqlQuery[[
		INSERT INTO word (word) VALUES ('<end>');
		]]
		assert(success, err)
	end
end

function setupTables()
	local success, err = sqlQuery[[
	CREATE TABLE word(
		id SERIAL NOT NULL PRIMARY KEY,
		word VARCHAR(64) NOT NULL UNIQUE,
		count INTEGER NOT NULL DEFAULT 0
	);
	]]
	assert(success, err)
	local success, err = sqlQuery[[
	CREATE TABLE word_word(
		id SERIAL NOT NULL PRIMARY KEY,
		word_from INTEGER NOT NULL,
		word_to INTEGER NOT NULL,
		weight INTEGER NOT NULL DEFAULT 0
	);
	]]
	assert(success, err)
	local success, err = sqlQuery[[
	CREATE UNIQUE INDEX word_idx ON word (word);
	CREATE INDEX word_word_idx ON word_word (word_from, word_to);
	]]
	assert(success, err)
	res:close()
end

function close()
	con:close()
	env:close()
end

local function sqlQueryOneValue(query)
	local res, err = sqlQuery(query)
	assert(res, err)
	local val = res:fetch()
	res:close()
	return val
end

function getStats()
	return sqlQueryOneValue "SELECT COUNT(id) AS word_count FROM word;", sqlQueryOneValue "SELECT COUNT(id) AS relation_count FROM word_word;"
end

function generateSentence()
	local last = findOrInsertWord('<start>')
	local eid = findOrInsertWord('<end>')
	local last = sqlQueryOneValue(("SELECT word_to FROM word_word WHERE word_from = %d ORDER BY (abs(random())/10000)*weight DESC LIMIT 1;"):format(last))
	local str = sqlQueryOneValue(("SELECT word FROM word WHERE id = %d LIMIT 1;"):format(last))
	while last and last ~= eid do
		last = sqlQueryOneValue(("SELECT word_to FROM word_word WHERE word_from = %d ORDER BY (abs(random())/10000)*weight DESC LIMIT 1;"):format(last))
		local word = sqlQueryOneValue(("SELECT word FROM word WHERE id = %d LIMIT 1;"):format(last))
		if word == '<end>' then break; end
		str = str .. ' ' ..  word
	end
	return str:sub(1, 1):upper() .. str:sub(2) .. '.'
end

function generateSentenceFromWord(word)
	local start = findOrInsertWord('<start>')
	local eid = findOrInsertWord('<end>')
	local last = word
	local str = sqlQueryOneValue(("SELECT word FROM word WHERE id = %d LIMIT 1;"):format(word))
	if not str then return generateSentence(), false; end
	while last and last ~= eid do
		last = sqlQueryOneValue(("SELECT word_to FROM word_word WHERE word_from = %d ORDER BY (abs(random())/10000)*weight DESC LIMIT 1;"):format(last))
		local word = sqlQueryOneValue(("SELECT word FROM word WHERE id = %d LIMIT 1;"):format(last))
		if word == '<end>' then break; end
		str = str .. ' ' ..  word
	end
	local last = word
	while last and last ~= start do
		last = sqlQueryOneValue(("SELECT word_from FROM word_word WHERE word_to = %d ORDER BY (abs(random())/10000)*weight DESC LIMIT 1;"):format(last))
		local word = sqlQueryOneValue(("SELECT word FROM word WHERE id = %d LIMIT 1;"):format(last))
		if word == '<start>' then break; end
		str = word .. ' ' .. str
	end
	return str:sub(1, 1):upper() .. str:sub(2) .. '.', true
end

function generateSentenceFromString(context)
	local tbl = {}
	for word in context:gmatch(WORD_PATTERN) do
		tbl[#tbl + 1] = findOrInsertWord(word:lower())
	end
	local cw = sqlQueryOneValue(
		("SELECT id FROM word WHERE id IN (%s) AND count > 2 ORDER BY count ASC LIMIT 1;"):format(table.concat(tbl, ', '))
	)
	if not cw then return generateSentence(), false; end
	return generateSentenceFromWord(cw)
end

function add(text)
	for sentence in text:gmatch(SENTENCE_PATTERN) do
		addSentence(sentence)
	end
end

function addSentence(sentence)
	local tbl = {}
	local relations = {}
	for word in sentence:gmatch(WORD_PATTERN) do
		tbl[#tbl + 1] = word:lower()
	end
	local wTable = {}
	for k,v in ipairs(tbl) do
		wTable[#wTable + 1] = addWord(v)
		relations[#relations + 1] = {tbl[k - 1] or '<start>', v}
	end
	if #wTable > 0 then
		assert(sqlQuery(("UPDATE word SET count = count + 1 WHERE id IN (%s);"):format(table.concat(wTable, ', '))))
	end
	local rTable = {}
	for k,v in ipairs(relations) do
		rTable[#rTable + 1] = findOrInsertRelation(findOrInsertWord(v[1]), findOrInsertWord(v[2]))
	end
	if not relations[#relations] then return end
	rTable[#rTable + 1] = findOrInsertRelation(findOrInsertWord(relations[#relations][2]), findOrInsertWord('<end>'))
	assert(sqlQuery(("UPDATE word_word SET weight = weight + 1 WHERE id IN (%s);"):format(table.concat(rTable, ', '))))
end

function addWord(word)
	return findOrInsertWord(word)
end

function findOrInsertWord(word)
	if words[word] then -- Check that the word isn't cached (if it is, we know that it already exists in the database).
		return words[word]
	end
	local eword = escapeString(word)
	local row = sqlQueryOneValue(("SELECT id FROM word WHERE word = '%s' LIMIT 1;"):format(eword))
	if row then
		words[word] = tonumber(row)
		return words[word]
	end
	local res, err = sqlQuery(("INSERT INTO word (word) values ('%s');"):format(eword))
	assert(res, err)
	local row = sqlQueryOneValue("SELECT currval('word_id_seq');")
	words[word] = tonumber(row)
	return words[word]
end

function findOrInsertRelation(from, to)
	if relations[from] and relations[from][to] then
		return relations[from][to]
	end
	local row = sqlQueryOneValue(("SELECT id FROM word_word WHERE word_from = %d AND word_to = %d LIMIT 1;"):format(from, to))
	if row and tonumber(row) then
		relations[from] = relations[from] or {}
		relations[from][to] = tonumber(row)
		return tonumber(row)
	end
	local res, err = sqlQuery(("INSERT INTO word_word (word_from, word_to) values (%d, %d);"):format(from, to))
	assert(res, err)
	local row = sqlQueryOneValue("SELECT currval('word_word_id_seq');")
	relations[from] = relations[from] or {}
	relations[from][to] = tonumber(row)
	return tonumber(row)
end

function escapeString(str)
	return str:gsub("'", "''")
end
