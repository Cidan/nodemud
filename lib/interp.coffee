walk = require 'walk'
events = require 'events'
# Every interp created has a local state just for that player.
class Interp extends events.EventEmitter

	onMulti: (evs, fn) ->
		@on(ev, fn) for ev in evs

	parse: (player, line) ->
		log.warn "Interp has no parse method defined, user input was not parsed."

	onLoad: (player) ->
	prompt: (player) ->

# Static
Interp.interps = {}
# Load our interps.
Interp.init = (cb) ->
	log.info "Loading interps..."
	walker = walk.walk "/home/alobato/nodemud/lib/interp/"
	walker.on "file", (root, fileStats, next) ->
		log.info "Loading interp: #{fileStats.name}"
		Interp.interps[fileStats.name] = require "#{root}/#{fileStats.name}"
		next()
	walker.on "end", () ->
		log.info "Interps loaded."
		cb()

Interp.get = (name) ->
	return Interp.interps[name] or Interp.interps["#{name}.coffee"] or null
	
module.exports = Interp