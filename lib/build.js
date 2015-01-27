var events = require("events");
var util = require('util');

function Build(){
	// Disable OLC
	this.on("build", this.build);

	// Room
	this.on("dig", this.dig);

	// Edit
	this.on("edit", this.edit);
}
util.inherits(Build, events.EventEmitter);

Build.prototype.parse = function(player, cmd, args){
	if (this.listeners(cmd).length == 0){
		return;
	} else {
		this.emit(cmd, player, args);
	}
}

Build.prototype.build = function(player, input){
	player.set("building", false);
	player.send("Online Creation Mode {RDisabled{x", true);
}

Build.prototype.dig = function(player, input){
	if (input == "" || input == undefined){
		player.send("Dig which way? (Or, type 'dig auto' to turn on auto dig.", true);
		return;
	}
	if (input == "auto"){
		if (player.get("autodig")){
			player.set("autodig", false);
			player.send("Auto digging disabled.", true);
		} else {
			player.set("autodig", true);
			player.send("Auto digging enabled. Move in a direction and you will create rooms as you walk.", true);
		}
		return;
	}
	player.send("soon", true);
}

Build.prototype.edit = function(player, input){
	if ((input == "" || input == undefined)){
		if (player.get("editing")){
			player.set("editing", false);
			player.send("Okay, you are no longer in edit mode.", true);
		} else {
			player.buffer("What would you like to edit?", true);
			player.buffer("edit 'room', or, edit <UUID>", true);
			player.flush();
		}
		return;
	}

	if (input == "room"){
		player.set("editing", {
			type: 'room'});
		player.send("Okay, you are now in room edit mode. You will always edit the room you are standing in.", true);
		return;
	}
}

Build.prototype.set = function(player, input){
}

Build.prototype.remove = function(player, input){
}

Build.prototype.add = function(player, input){
}

module.exports = Build;
