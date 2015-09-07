Entity = require './entity'
readline = require 'readline'
fs = require 'fs'

class Player extends Entity
	constructor: () ->
		super
		@_buffer = ""
		@set 'type', 'player'

	loadFromData: (data) =>
		@vars = data.vars
		@updateMetaData()

	setSocket: (socket) =>
		# TODO if socket exists, ld the old socket
		@socket = socket
		@socket.on 'error', () =>
			@linkdead()
		@rl = readline.createInterface {
			input: socket,
			output: socket
		}
		@rl.on 'line', (line) =>
			@parse line

	linkdead: () =>

	disconnect: () =>
		@socket.end()
		@socket.unref()
		@socket.destroy()
		@rl.close()
	
	# Remove the player from the world.
	cleanup: () =>
		# TODO: Check if connected, delete connection
		#@socket = null
		#@vars = null

	quit: () =>
		@disconnect()
		@save (err) =>
			@from_room()

	setInterp: (interp) =>
		@interp = Interp.get(interp)
		@interp.onLoad this

	parse: (input) ->
		if not @interp
			log.error "Player has no iterp. Eep."
			return
		@interp.parse this, input
	
	prompt: () =>
		if not @interp
			log.error "Player has no interp for a prompt."
			return
		@interp.prompt(this)

	sendRaw: (text, cb) =>
		@socket.write color("#{text}"), "UTF8", cb
	
	send: (text, newline, cb) ->
		if not text
			log.error "Sending a player an empty text string!"
		if newline
			@socket.write color("#{text}\n\n"), "UTF8", cb
		else
			@socket.write color("#{text}"), "UTF8", cb
		@prompt()

	buffer: (text, newline) =>
		@_buffer += text
		if newline
			@_buffer += "\n"

	flush: (newline) ->
		@send @_buffer, newline
		@_buffer = ""

	to_room: (coord) =>
		if @room
			@from_room()
		# If coord is null, something wrong happened and we're moving them to room [0,0,0]
		coord ?= [0,0,0]
		newRoom = Room.exists coord
		if newRoom
			@set 'room', coord
			newRoom.add_entity this
			@room = newRoom
		else
			# TODO: move to recall or safe room.
			log.debug "Attempted to move player to room that does not exist: #{coord[0]} #{coord[1]} #{coord[2]}"
	
	from_room: () =>
		if @room
			@set 'room', null
			@room.remove_entity this
			@room = undefined

# Static methods
Player.init = (cb) ->
	log.info "Making player hash directories"
	Common.make_hash_dir "#{config.get('data_dir')}player/", 3
	cb()

module.exports = Player
