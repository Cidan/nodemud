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
		filename = "/home/alobato/nodemud/data/players/#{md5[0]}/#{md5[1]}/#{md5[2]}/#{md5}"
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
	Common.make_hash_dir "/home/alobato/nodemud/data/players/", 3
	cb()
###
var util = require('util');
var readline = require('readline');
var fs = require('fs');
var Entity = require("./entity.js");

function Player(socket, save_map){

	if (save_map){
		this.vars = save_map.vars;
		this.set("state", "ask_password");
	} else {
		this.set("type", "player");
		this.set("state", "ask_name");
	}
}
util.inherits(Player, Entity);

Player.init = function(){
	Nanny = require('./nanny');
	Log.info("Making player hash directories");
	Common.make_hash_dir("/home/alobato/nodemud/data/players/", 3);
	Player.loaded = {};
}

Player.load = function(name, cb){
	var md5 = Common.hash(name, "md5");
	var filename = "/home/alobato/nodemud/data/players/" + md5[0] +
	"/" + md5[1] +
	"/" + md5[2] +
	"/" + md5;
	fs.exists(filename, function(exists){
		if (!exists){
			cb(false);
			return;
		}
		fs.readFile(filename, function(err, save_map){
			cb(JSON.parse(save_map));
		});
	});
}

Player.is_loaded = function(name){
	return Player.loaded[name];
}

Player.prototype.load = function(save_map){
	if (Player.loaded[this.vars.name])
		delete Player.loaded[this.vars.name];

	// Trigger index update.
	this.update_uuid(save_map.vars.uuid);
	this.set_name(save_map.vars.name);

	this.vars = save_map.vars;
	Player.loaded[this.vars.name] = this;
};

Player.prototype.send = function(text, newline, cb){
	text = text.color();
	if (newline)
		this._socket.write(text + "\n", "UTF8", cb)
	else
		this._socket.write(text, "UTF8", cb)
	if (this.get("state") == "playing")
		this._socket.write("\n" + (this.prompt() + "{x").color(), "UTF8", cb);
}

Player.prototype.prompt = function(){
	if (this.get("building")){
		var str = "<Building";
		if (this.get("autodig"))
			str += " | {RAUTODIG{x";
		str += ">";
		var editing = this.get("editing");
		if (editing){
			if (editing.type == 'room'){
				str += "\n<Editing room: " + this.room.get("name") + " (" + this.room.uuid() + ")>";
			}
		}
		return str;
	} else {
	return "<100h 100m 100v>";
	}
}
Player.prototype.to_room = function(x, y, z){
	var c_room = this.get("room");
	if (c_room){
		var current_room = Room.exists(c_room[0], c_room[1], c_room[2]);
		current_room.remove_entity(this);
		this.room = undefined;
	}
	var room = Room.exists(x, y, z);
	if (room){
		this.set("room", [x, y, z]);
		room.add_entity(this);
		this.room = room;
	} else {
		console.log("Room does not exist:" + x + " " + y + " " + z);
	}
}

Player.prototype.from_room = function(){
	if (!this.room)
		return;
	this.room.remove_entity(this);
	this.room = undefined;
}

Player.prototype.cmd = function(cmd, args){
	Nanny.interp.parse(this, cmd, args); 
}

Player.prototype.set_name = function(name){
	this.vars.md5 = Common.hash(name, "md5");
	if (Player.loaded[this.vars.name]){
		delete Player.loaded[this.vars.name];
	}
	this.vars.name = name;
	Player.loaded[name] = this;
}

Player.prototype.get_name = function(){
	return this.vars.name;
}

Player.prototype.save = function(cb){
	if (this._saving)
		return;
	this._saving = true;
	Log.debug("Starting player save of " + this.get_name());
	var self = this;
	var filename = "/home/alobato/nodemud/data/players/" + this.vars.md5[0] +
	"/" + this.vars.md5[1] +
	"/" + this.vars.md5[2] +
	"/" + this.vars.md5;
	var save_map = {
		vars: this.vars
	}
	fs.writeFile(filename, JSON.stringify(save_map), function(){
		self._saving = false;
		Log.debug(self.get_name() + " saved.");
		if (cb)
			cb();
	});
}

Player.prototype.disconnect = function(){
	this._socket.end();
}

Player.prototype.quit = function(){
	this._socket.end();
	this.from_room();
	delete Player.loaded[this.vars.name];
	this.linkdead();
	this.remove();
	this.vars = undefined;
}

Player.prototype.linkdead = function(){
	this._socket.removeAllListeners("error");
	this._rl.removeAllListeners("line");
	this._socket = undefined;
	this._rl = undefined;
}
###
module.exports = Player
