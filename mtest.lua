require 'markov'
--dofile 'file.lua'

--local txt = _file.Read("gmod-wikipedia.txt")

markov.setup()
print(markov.generateSentenceFromString("What is wire?"))
markov.close()