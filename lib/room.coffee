util = require 'util'
fs = require 'fs'
walk = require 'walk'
mkdirp = require 'mkdirp'
Entity = require './entity'

# Class and instance methods
class Room extends Entity
	constructor: (data) ->
		super
		if data
			@updateMetaData()
			@vars = data
			@set_coordinates [@vars._x, @vars._y, @vars._z], true
		
		Room.set_defaults(this)
		Room.list[this.uuid()] = this
		@in_room = {}

	# Set the coordinates of the room in the world space.
	# Note, this makes the room live/active.
	set_coordinates: (coord, nosave) =>
		x = coord[0]
		y = coord[1]
		z = coord[2]
		Room.matrix[x] ?= []
		Room.matrix[x][y] ?= []
		
		@unlink_room()
		
		@set "_x", x, true
		@set "_y", y, true
		@set "_z", z, true
		Room.matrix[x][y][z] = this
		@set "md5", Room.generate_location_hash(coord), true
		if !nosave
			@save()

	# Get a list of the coords of this room, x, y, z.
	get_coordinates: () =>
		return [@vars._x, @vars._y, @vars._z]

	# Unlink a room from the world entirely.
	unlink_room: () =>
		try
			delete Room.matrix[@get('_x')][@get('_y')][@get('_z')]
		return true

	# Set the room name
	set_name: (name) =>
		@set 'name', name

	# Get the room name
	get_name: () =>
		return @get 'name'

	set_description: (description) =>
		@set 'description', description

	get_neighbor_coord: (dir) =>
		coord = @get_coordinates()
		switch dir
			when 'east', 'e'
				return [coord[0] + 1, coord[1], coord[2]]
			when 'west', 'w'
				return [coord[0] - 1, coord[1], coord[2]]
			when 'north', 'n'
				return [coord[0], coord[1] + 1, coord[2]]
			when 'south', 's'
				return [coord[0], coord[1] - 1, coord[2]]
			when 'up', 'u'
				return [coord[0], coord[1], coord[2] + 1]
			when 'down', 'd'
				return [coord[0], coord[1], coord[2] - 1]
			else
				return false

	has_exit: (dir) =>
		coord = @get_coordinates()
		return Room.exists(@get_neighbor_coord(dir))
		
	save: () =>
		if @_saving
			return
		@_saving = true
		log.debug "Staring room save of " + this.uuid() + " (" + this.get_name() + ")"
		self = this
		filename = "/home/alobato/nodemud/data/rooms/" + this.vars.md5[0] +
		"/" + this.vars.md5[1] + 
		"/" + this.vars.md5[2] +
		"/" + this.vars.md5
		fs.writeFile filename, JSON.stringify({
			vars: @vars,
			objs: @in_room.object
		}), () =>
			@_saving = false
			log.debug "#{@uuid()} saved."

	add_entity: (entity) ->
		type = entity.type()
		if !@in_room[type]
			@in_room[type] = {}
		@in_room[type][entity.uuid()] = entity

	remove_entity: (entity) ->
		type = entity.type()
		if @in_room[type]
			delete @in_room[type][entity.uuid()]

# Static class methods
Room.matrix = []
Room.list = {}

Room.init = (cb) ->
	log.info "Creating room hash directories"
	Common.make_hash_dir "/home/alobato/nodemud/data/rooms/", 3
	cb()

Room.create_default = () ->
	room = new Room()
	room.set_name "Starting Room"
	room.set_description "Starting Description"
	room.set_coordinates [0, 0, 0]

	room2 = new Room()
	room.set_name "Room 2"
	room.set_description "Starting Description"
	room.set_coordinates [1, 0, 0]

Room.exists = (coord) ->
	x = coord[0]
	y = coord[1]
	z = coord[2]
	if Room.matrix[x] and Room.matrix[x][y] and Room.matrix[x][y][z]
		return Room.matrix[x][y][z]
	return false

Room.load_all = (cb) ->
	log.info "Loading previously saved rooms."
	walker = walk.walk "/home/alobato/nodemud/data/rooms"
	walker.on "file", (root, fileStats, next) ->
		fs.readFile root + "/" + fileStats.name, (err, save_map) ->
			save_map = JSON.parse save_map
			new Room save_map.vars
			log.debug "#{fileStats.name} (#{save_map.vars.name}) loaded. [#{save_map.vars._x} #{save_map.vars._y} #{save_map.vars._z}]"
			# TODO: load save_map.objs
			next()
	walker.on "end", () ->
		log.info "World load {Gcomplete{x!"
		cb()

Room.load = (coord) ->
	log.warn "Not yet on Room.load"

Room.generate_location_hash = (coord) ->
	return Common.hash coord[0] + " " + coord[1] + " " + coord[2], "md5"

# Set default variables for this room.
Room.set_defaults = (room) ->
	rv = room.vars
	rv.name ?= "New Room"
	rv.description ?= "This room is not yet rated."

module.exports = Room