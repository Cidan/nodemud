Entity = require './entity'
readline = require 'readline'
fs = require 'fs'

class Player extends Entity
	constructor: () ->
		super
		@_buffer = ""
		@set 'type', 'player'

	load: (cb) =>
		md5 = Common.hash(@get('name'), 'md5')
		filename = "#{config.get('data_dir')}players/#{md5[0]}/#{md5[1]}/#{md5[2]}/#{md5}"
		fs.readFile filename, (err, saved_data) ->
			if err
				cb err
			else
				cb null, JSON.parse(saved_data)

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

	linkdead: () ->

	disconnect: () ->
		@socket.end()
	
	cleanup: () ->
		# TODO: Check if connected, delete connection
		#@socket = null
		#@vars = null
	
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
		@socket.write "#{text.color()}", "UTF8", cb
	
	send: (text, newline, cb) ->
		if not text
			log.error "Sending a player an empty text string!"
		if newline
			@socket.write "#{text.color()}\n\n", "UTF8", cb
		else
			@socket.write "#{text.color()}", "UTF8", cb
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
		newRoom = Room.exists coord
		if newRoom
			@set 'room', coord
			newRoom.add_entity this
			@room = newRoom
		else
			# TODO: move to recall or safe room.
			log.debug "Room does not exist in toRoom: #{x} #{y} #{z}"
	
	from_room: () =>
		if @room
			@set 'room', null
			@room.remove_entity this
			@room = undefined

# Static methods
Player.init = (cb) ->
	log.info "Making player hash directories"
	Common.make_hash_dir "#{config.get('data_dir')}players/", 3
	cb()

module.exports = Player
