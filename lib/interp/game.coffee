# Stateless modules that handle various input modes.
class Game extends Interp
	constructor: () ->
		@onMulti ['l', 'look'], @look
		@onMulti ['e', 'east'], @east
		@onMulti ['w', 'west'], @west
		@onMulti ['n', 'north'], @north
		@onMulti ['s', 'south'], @south
		@onMulti ['u', 'up'], @up
		@onMulti ['d', 'down'], @down

	parse: (player, input) =>
		inputs = input.split(" ")
		cmd = inputs.shift()
		args = inputs.join " "
		if @listeners(cmd).length == 0
			player.send "Huh?"
		else
			@emit cmd, player, args

	look: (player, args) =>
		room = player.room
		coord = room.get_coordinates()
		player.buffer map.generate(room, 5, 2)
		player.buffer room.get('name'), true
		player.buffer "  #{room.get('description')}", true
		
		# TODO: hidden, closed exits
		player.buffer "\n{c[Exits:"
		if room.has_exit 'east'
			player.buffer " east"
		if room.has_exit 'west'
			player.buffer " west"
		if room.has_exit 'north'
			player.buffer 'north'
		if room.has_exit 'south'
			player.buffer 'south'
		if room.has_exit 'up'
			player.buffer 'up'
		if room.has_exit 'down'
			player.buffer 'down'

		player.buffer "]{x", false
		player.flush()

	move: (player, dir) =>
		current_room = player.room
		target_room = current_room.has_exit(dir)
		if not target_room
			player.send "Alas, you cannot go that way.", false
			return
		player.to_room(target_room.get_coordinates())
		@look(player)

	east: (player) =>
		@move player, 'east'
	west: (player) =>
		@move player, 'west'
	north: (player) =>
		@move player, 'north'
	south: (player) =>
		@move player, 'south'
	up: (player) =>
		@move player, 'up'
	down: (player) =>
		@move player, 'down'


module.exports = new Game
###
var events = require("events");
var util = require('util');
var Room = require('./room');
var Map = require('./map');
var Build = require('./build');
var Entity = require('./entity');

function Interp(){
	var self = this;
	Interp.build = new Build();

	// Look
	this.on("look", this.look);
	this.on("l", this.look);

	// Movement
	this.on("north", this.north);
	this.on("south", this.south);
	this.on("east", this.east);
	this.on("west", this.west);
	this.on("down", this.down);
	this.on("up", this.up);

	this.on("n", this.north);
	this.on("s", this.south);
	this.on("e", this.east);
	this.on("w", this.west);
	this.on("d", this.down);
	this.on("u", this.up);

	// Save
	this.on("save", this.save);

	// Quit
	this.on("quit", this.quit);

	// OLC
	this.on("build", this.build);

	// Searching
	this.on("locate", this.locate);
}
util.inherits(Interp, events.EventEmitter);


Interp.prototype.parse = function(player, input, args){
	var cmd;
	if (args == undefined){
		input = input.split(" ");
		cmd = input.shift();
		args = input;
	} else {
		cmd = input;
	}
	if (cmd == ""){
		player.send("", true);
	} else if (player.get("building")){
		if (Interp.build.listeners(cmd).length != 0){
			Interp.build.parse(player, cmd, args);
		} else if (this.listeners(cmd).length != 0){
			this.emit(cmd, player, args);
		} else {
			player.send("There is no such build command.", true);
		}
	} else if (this.listeners(cmd).length == 0){
		player.send("Huh?", true);
	} else {
		this.emit(cmd, player, args);
	}
}

Interp.prototype.look = function(player, input){
	var room_dir = player.get("room");
	room = Room.exists(room_dir[0], room_dir[1], room_dir[2]);
	player.buffer(Map.generate(room, 5, 2));
	player.buffer(room.get("name"), true);
	player.buffer("  " + room.get("description"), true);

	// TODO: Hidden, closed exits.
	var exit = false;
	player.buffer("\n{c[Exits:");

	if (Room.exists(room_dir[0] + 1, room_dir[1], room_dir[2])){
		exit = true;
		player.buffer(" east");
	}

	if (Room.exists(room_dir[0] - 1, room_dir[1], room_dir[2])){
		exit = true;
		player.buffer(" west");
	}

	if (Room.exists(room_dir[0], room_dir[1] + 1, room_dir[2])){
		exit = true;
		player.buffer(" north");
	}

	if (Room.exists(room_dir[0], room_dir[1] - 1, room_dir[2])){
		exit = true;
		player.buffer(" south");
	}

	if (Room.exists(room_dir[0], room_dir[1], room_dir[2] + 1)){
		exit = true;
		player.buffer(" up");
	}

	if (Room.exists(room_dir[0], room_dir[1], room_dir[2] - 1)){
		exit = true;
		player.buffer(" down");
	}

	if (!exit)
		player.buffer(" none");

	player.buffer("]{x", true);
	player.flush();
}

// Movement commands
Interp.prototype.east = function(player, input){
	this.move(player, "east");
}

Interp.prototype.west = function(player, input){
	this.move(player, "west");
}

Interp.prototype.north = function(player, input){
	this.move(player, "north");
}

Interp.prototype.south = function(player, input){
	this.move(player, "south");
}

Interp.prototype.up = function(player, input){
	this.move(player, "up");
}

Interp.prototype.down = function(player, input){
	this.move(player, "down");
}

Interp.prototype.move = function(player, dir){
	var c_room = player.get("room");
	var current_room = Room.exists(c_room[0], c_room[1], c_room[2]);

	var t_room = c_room.slice(0);

	switch (dir){
	case "north":
		t_room[1] += 1;
		break;
	case "south":
		t_room[1] -= 1;
		break;
	case "east":
		t_room[0] += 1;
		break;
	case "west":
		t_room[0] -= 1;
		break;
	case "up":
		t_room[2] += 1;
		break;
	case "down":
		t_room[2] -= 1;
		break;
	}

	var target_room = Room.exists(t_room[0], t_room[1], t_room[2]);
	if (!target_room){
		player.send("Alas, you cannot go that way.", true);
		return;
	}
	player.to_room(t_room[0], t_room[1], t_room[2]);
	player.cmd("look", "");
}

Interp.prototype.save = function(player, input){
	player.save();
	player.send("Player saved. Remember that we have automatic saving now.", true);
}

Interp.prototype.quit = function(player, input){
	player.save(function(){
		player.set("state", "quitting");
		player.send("See ya.", true);
		player.quit();
		// TODO: Disconnect here.
	});
}

Interp.prototype.build = function(player, input){
	player.set("building", true);
	player.send("Online Creation Mode {GEnabled{x", true);
}

Interp.prototype.locate = function(player, input){
	if (input == "" || input == undefined){
		player.send("What are you looking for?", true);
		return;
	}
	var results = Entity.find(input[0]);
	if (results.length == 0){
		player.send("Sorry, no results found. :(", true);
		return;
	}
	player.buffer("Okay, I found the following stuff:\n", true);
	results.forEach(function(result, i){
		var entity = Entity._all[result.uuid];
		player.buffer((i + 1) + ".\n---\n");
		player.buffer("Name: " + entity.get("name"), true);
		player.buffer("Type: " + entity.get("type"), true);
		player.buffer("UUID: " + entity.uuid(), true);
		if (entity.room)
			player.buffer("Location: " + entity.room.get("name") + " (" + entity.uuid() + ")", true);
		player.buffer("\n");
	});
	player.flush();
}

module.exports = Interp;
###