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
		@on 'build', @build
		@on 'save', @save

	parse: (player, input) =>
		inputs = input.split(" ")
		cmd = inputs.shift()
		args = inputs.join " "
		if cmd == ""
			player.prompt()
		else if @listeners(cmd).length == 0
			player.send "Huh?"
		else
			@emit cmd, player, args

	prompt: (player) =>
		player.sendRaw '\n\n<{G100{xh {G100{xm {G100{xv>'

	build: (player, args) =>
		player.setInterp 'build'
		player.set 'building', true
		player.send 'Building enabled.'

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
			player.buffer ' north'
		if room.has_exit 'south'
			player.buffer ' south'
		if room.has_exit 'up'
			player.buffer ' up'
		if room.has_exit 'down'
			player.buffer ' down'

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

	save: (player) =>
		player.save (err) ->
			if err
				player.send "Uh oh, there was an error saving you. The error has been logged."
			else
				player.send "Your player has been saved."
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