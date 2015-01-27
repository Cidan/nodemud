require 'date-utils'

class Log
	constructor: (@strip_color) ->

	info: (txt) ->
		if txt
			txt = txt.color @strip_color
		console.info this.time() + ": [{gINFO{x]  ".color(@strip_color) + txt

	warn: (txt) ->
		if txt
			txt = txt.color @strip_color
		console.info this.time() + ": [{yWARN{x]  ".color(@strip_color) + txt

	error: (txt) ->
		if txt
			txt = txt.color @strip_color
		console.info this.time() + ": [{RERROR{x]  ".color(@strip_color) + txt

	debug: (txt) ->
		if txt
			txt = txt.color @strip_color
		console.info this.time() + ": [{BDEBUG{x]  ".color(@strip_color) + txt

	time: () ->
		return new Date().toFormat "DDD MMM DD YYYY HH24:MI:SS"

module.exports = new Log
