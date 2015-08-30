events = require 'events'
async = require 'async'

# Static classes/objects
global.config = require 'config'
global.log = require './log'
global.map = require './map'
# Classes
global.Common = require './common'
global.Server = require './server'
global.Room = require './room'
global.Player = require './player'
global.Color = require './color'
global.Debug = require './debug'
global.Interp = require './interp'

class Hub extends events.EventEmitter
	constructor: (@server) ->

	start: ->
		ops = []
		ops.push Room.init
		ops.push Player.init
		ops.push Interp.init
		ops.push Room.load_all
		ops.push (cb) ->
			global.server = new Server(4000)
			server.on 'connection', (socket) ->
				new_player = new Player()
				new_player.setSocket socket
				new_player.setInterp "login"
			server.listen()

		async.series ops

module.exports = new Hub
