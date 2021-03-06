events = require 'events'
async = require 'async'

# Static classes/objects
global.config = require 'config'
global.color = require './color'
global.log = require './log'
global.map = require './map'
global.editor = require './editor'
global.cli = require './cli'

# Classes
global.Common = require './common'
global.Server = require './server'
global.Entity = require './entity'
global.Room = require './room'
global.Player = require './player'
global.Debug = require './debug'
global.Interp = require './interp'
global.NPC = require './npc'
class Hub extends events.EventEmitter
	constructor: (@server) ->

	start: ->
		ops = []
		ops.push Room.init
		ops.push Player.init
		ops.push NPC.init
		ops.push Interp.init
		ops.push Room.load_all
		ops.push (cb) ->
			global.server = new Server(config.get('port'))
			server.on 'connection', (socket) ->
				new_player = new Player()
				new_player.setSocket socket
				new_player.setInterp "login"
			server.listen()
			cb()
		ops.push cli.init
		
		async.series ops

module.exports = new Hub
