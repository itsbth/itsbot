require('profiler')
require('os')

os.execute("del data\\markov.db")

profiler.start('mtest.out')
dofile('mtest.lua')
profiler.stop()
