util = require 'util'

class Debug
	constructor: () ->
		@agent = require 'webkit-devtools-agent'
		process.kill process.pid, 'SIGUSR2'
		@memwatch = require 'memwatch'

		@memwatch.on 'leak', (info) ->
			global.log.debug "{RHeap increase{x\n" + util.inspect(info)

		@memwatch.on 'stats', (stats) ->
			global.log.debug "{GGC{x:\n" + util.inspect(stats)

		@diffs = {}
		global.log.debug "{GHeap Debugging enabled{x"
		global.log.debug "{MDEBUG URLS{x"
		global.log.debug "{Yhttp://jinked.com/wk/inspector.html?host=jinked.com:9999&page=0{x"

	diff: (id, timer) ->
		self = this
		if @diffs[id]
			global.log.debug "Error starting diff with id '" + id + "', there is a diff by that id already running."
			return false
		
		if timer
			ef = () ->
				self.end id
			tref = setTimeout ef, timer
			@diffs[id] = {
				diff: new @memwatch.HeapDiff(),
				tref: tref
			}

	end: (id) ->
		if !@diffs[id]
			global.log.debug "Error ending diff with id '" + id + "', there are no diffs by that id running."
			return false
		dt = @diffs[id].diff.end()
		global.log.debug "Diff of id '{R" + id + "{x':\n" + util.inspect(dt)
		delete @diffs[id]

module.exports = Debug