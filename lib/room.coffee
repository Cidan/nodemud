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
		Room.list[this.uuid()] = this
		@in_room = {}

	set_coordinates: (coord, nosave) =>
		x = coord[0]
		y = coord[1]
		z = coord[2]
		if @vars._x and @vars._y and @vars._z
			delete Room.matrix[@vars._x][@vars._y][@vars._z]
		
		if Room.matrix[x] == undefined
			Room.matrix[x] = []
		if Room.matrix[x][y] == undefined
			Room.matrix[x][y] = []
		this.set "_x", x, true
		this.set "_y", y, true
		this.set "_z", z, true
		Room.matrix[x][y][z] = this
		this.set "md5", Room.generate_location_hash(coord), true
		if !nosave
			this.save()

	get_coordinates: () ->
		return [@vars._x, @vars._y, @vars._z]

	set_name: (name) ->
		@vars.name = name

	get_name: () ->
		return @vars.name

	set_description: (description) ->
		@vars.description = description

	has_exit: (dir) =>
		coord = @get_coordinates()
		switch dir
			when 'east'
				return Room.exists [coord[0] + 1, coord[1], coord[2]]
			when 'west'
				return Room.exists [coord[0] - 1, coord[1], coord[2]]
			when 'north'
				return Room.exists [coord[0], coord[1] + 1, coord[2]]
			when 'south'
				return Room.exists [coord[0], coord[1] - 1, coord[2]]
			when 'up'
				return Room.exists [coord[0], coord[1], coord[2] + 1]
			when 'down'
				return Room.exists [coord[0], coord[1], coord[2] - 1]
			else
				return false
		
	save: () =>
		if @_saving
			return
		@_saving = true
		log.debug "Staring room save of " + this.uuid() + " (" + this.get_name + ")"
		self = this
		filename = "/home/alobato/nodemud/data/rooms/" + this.vars.md5[0] +
		"/" + this.vars.md5[1] + 
		"/" + this.vars.md5[2] +
		"/" + this.vars.md5
		fs.writeFile filename, JSON.stringify {
			vars: @vars,
			objs: @in_room.object
		}, () =>
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

#Room.prototype.save = function(){
#	if (room._saving)
#		return
#	this._saving = true;
#	Log.debug("Staring room save of " + this.uuid() + " (" + this.get_name + ")");
#	var self = this;
#	var filename = "/home/alobato/nodemud/data/rooms/" + this.vars.md5[0] +
#	"/" + this.vars.md5[1] + 
#	"/" + this.vars.md5[2] +
#	"/" + this.vars.md5;
#	var save_map = {
#		vars: this.vars,
#		objs: this.in_room.object
#	}
#	fs.writeFile(filename, JSON.stringify(save_map), function(){
#		self._saving = false;
#		Log.debug(self.uuid() + " saved.");
#	});
#}

#Room.prototype.add_entity = function(entity){
#	var type = entity.type();
#	if (this.in_room[type] == undefined)
#		this.in_room[type] = {};
#	this.in_room[type][entity.uuid()] = entity;
#}
#
#Room.prototype.remove_entity = function(entity){
#	var type = entity.type();
#	if (this.in_room[type])
#		delete this.in_room[type][entity.uuid()];
#}
#Room.prototype.get_coordinates = function(){
#	return [this.vars._x, this.vars._y, this.vars._z];
#}
#
#Room.prototype.set_name = function(name){
#	this.vars.name = name;
#}
#
#Room.prototype.get_name = function(){
#	return this.vars.name;
#}
#
#Room.prototype.set_description = function(str){
#	this.vars.description = str;
#}



#Room.prototype.set_coordinates = function(x, y, z, nosave){
#	if (this.vars._x && this.vars._y && this.vars_z){
#		delete Room.matrix[this.vars._x][this.vars._y][this.vars._z];
#	}
#	if (Room.matrix[x] == undefined)
#		Room.matrix[x] = [];
#	if (Room.matrix[x][y] == undefined){
#		Room.matrix[x][y] = [];
#	}
#	if (Room.matrix[x][y][z] == undefined){
#		this.vars._x = x;
#		this.vars._y = y;
#		this.vars._z = z;
#		Room.matrix[x][y][z] = this;
#		this.vars.md5 = Room.generate_location_hash(x, y, z);
#		if (!nosave)
#			this.save();
#	}
#}

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
	log.info "Loading the world, ha ha ha"
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

module.exports = Room;

#Room.load_all = function(cb){
#	Log.info("Loading the world");
#	var walker = walk.walk("/home/alobato/nodemud/data/rooms");
#	walker.on("file", function(root, fileStats, next){
#		fs.readFile(root + "/" + fileStats.name, function(err, save_map){
#			save_map = JSON.parse(save_map);
#			new Room(save_map.vars);
#			Log.debug(fileStats.name + " (" + save_map.vars.name + ") loaded.");
#			// TODO: load save_map.objs
#			next();
#		});
#	});
#	walker.on("end", function(){
#		Log.info("World load {Gcomplete{x!");
#		cb();
#	});
#}

#Room.create_default = function(){
#	var room = new Room();
#	room.set_name("Starting Room");
#	room.set_description("Starting Description");
#	room.set_coordinates(0, 0, 0);
#	
#	var room2 = new Room();
#	room2.set_name("Room 2");
#	room2.set_description("Starting Description");
#	room2.set_coordinates(1, 0, 0);
#}

#Room.exists = function(x, y, z){
#	if (Room.matrix[x] && Room.matrix[x][y] && Room.matrix[x][y][z])
#		return Room.matrix[x][y][z];
#	return false;
#}

#function Room(data){
#	Room.super_.call(this);
#	if (data){
#		this.update_uuid(data.uuid);
#		this.vars = data;
#		this.set_coordinates(this.vars._x, this.vars._y, this.vars._z, true);
#	}
#	Room.list[this.uuid()] = this;
#	this.in_room = {};
#}
#util.inherits(Room, Entity);
#
#Room.matrix = [];
#Room.list = {};

#Room.init = function(){
#	Log = global.log;
#	Log.info("Creating room hash directories");
#	Common.make_hash_dir("/home/alobato/nodemud/data/rooms/", 3);
#}

