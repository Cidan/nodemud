# Static class that handles interp passing.
Nanny = {}
Nanny.interp = (player) ->

###
var Interp = require('./interp');
function Nanny(){
}

Nanny.init = function(){
	Nanny.interp = new Interp();
}

Nanny.parse = function(player, input){
	switch (player.get("state")){
	case 'playing':
		Nanny.interp.parse(player, input);
		break;
	case 'ask_name':
		if (input == undefined || input == "")
			player.send("By what name do you wish to be known?");
		else
			Nanny.check_name(player, input);
		break;
	case 'confirm_name':
		if (Common.isYes(input)){
			player.buffer("\nA note on passwords:", true);
			player.buffer(" Passwords are never stored in plain text, and", true);
			player.buffer(" are hashed with the SHA512 hash scheme.", true);
			player.buffer(" Immortals and Administrators do not have", true);
			player.buffer(" access to your password and can not tell you", true);
			player.buffer(" or anyone else what it is.\n", true);
			player.buffer(" That being said, this MUD does not use", true);
			player.buffer(" SSL/TLS for communication encryption. You", true);
			player.buffer(" should not use the same password as you do for", true);
			player.buffer(" your e-mail, etc.", true);
			player.buffer("\n\n tl;dr, {RUse a secret, but throw-away password.{x\n\n", true);
			player.flush();
			player.send("Give me a password for " + player.get("name") + ":");
			player.set("state", "ask_password");
		} else {
			player.send("Ok, what IS it, then?")
			player.set("state", "ask_name");
		}
		break;
	case 'ask_password':
		Nanny.check_pass(player, input);
		break;
	case 'confirm_password':
		Nanny.confirm_pass(player, input);
		break;
	case 'ask_side':
		break;
	}
}

Nanny.check_name = function(player, name){
	name = name.color(true).toLowerCase().capitalize();
	if (!name.isAlpha()){
		player.send("Your name is not valid.", true);
		player.send("Let's try this again, what name shall you go by?");
		return;
	}

	var old_player = Player.is_loaded(name);
	if (old_player && old_player._socket){
		player._reject = true;
		player._old = old_player;
		player._name = name;
		player.set("state", "ask_password");
		player.send("Password:");
		return;	
	}

	Player.load(name, function(save_map){
		if (save_map){
			player.load(save_map);
			player.set("loaded", true);
			player.set("state", "ask_password");
			player.send("Password:");
		} else {
			player.send("Did I get that right, " + name + " (Y/N)?");
			player.set_name(name);
			player.set("state", "confirm_name");
		}
	});
}

Nanny.check_pass = function(player, pass){
	// We are rejecting this player, but we need to fool them into thinking
	// they have a shot at logging in.
	if (player._reject && player._old && player._old._socket){
		Log.info("Player " + player._name + " tried to login a second time from address " + player._socket.remoteAddress);
		player.send("Wrong password. Your IP has been logged.", true, function(){
			player.quit();
		});
		return;
	}
	if (player.get("loaded")){
		var this_pass = Common.hash(pass);
		if (this_pass != player.get("password")){
			Log.info("Invalid password for " + player.get("name") + " from address " + player._socket.remoteAddress);
			player.send("Wrong password. Your IP has been logged.", true, function(){
				player.quit();
			});
		} else {
			Log.info("Player " + player.get("name") + " has logged in.");
			player.set("state", "playing");
			var room = player.get("room");
			player.to_room(room[0], room[1], room[2]);
			player.cmd("look", "");
		}
	} else {
		player.set("password", Common.hash(pass));
		player.set("state", "confirm_password");
		player.send("Please retype password:")
	}
}

Nanny.confirm_pass = function(player, pass){
	var hash = Common.hash(pass);
	if (hash != player.get("password")){
		player.send("Passwords don't match.", true);
		player.send("Retype password:");
		player.set("state", "ask_password");
	} else {
		player.set("state", "playing");
		player.to_room(0, 0, 0);
		player.cmd("look", "");
		player.save();
		// TODO: Kingdom tables
	}
}
###
module.exports = Nanny
