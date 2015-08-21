net = require 'net'
util = require 'util'
events = require 'events'
Player = require './player'

class Server
	constructor: (port) ->
		@port = port or 4000
		@server = net.createServer()

	on: (event, fn) ->
		@server.on event, fn

	listen: () ->
		@server.on 'error', (err) ->
			log.error(err)
				
		@server.listen @port
		log.info "Server is read to rock on port {G" + @port + "{x"

module.exports = Server
