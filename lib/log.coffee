require 'date-utils'

class Log
	constructor: (@strip_color) ->

	info: (txt) =>
		console.info color("#{@time()}: [{gINFO{x]  #{txt}", @strip_color)

	warn: (txt) =>
		console.info color("#{@time()}: [{yWARN{x]  #{txt}", @strip_color)

	error: (txt) =>
		console.info color("#{@time()}: [{RERROR{x]  #{txt}", @strip_color)

	debug: (txt) =>
		console.info color("#{@time()}: [{BDEBUG{x]  #{txt}", @strip_color)

	time: () =>
		return new Date().toFormat "DDD MMM DD YYYY HH24:MI:SS"

module.exports = new Log
