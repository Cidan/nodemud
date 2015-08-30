class Build extends Interp
	constructor: () ->
		@valid_dirs = ['north', 'n', 'east', 'e', 'south', 's', 'west', 'w', 'up', 'u', 'down', 'd']
		@on 'autodig', @autodig
		@on 'build', @build
		@on 'dig', @dig
		@on 'set', @set

	parse: (player, input) =>
		inputs = input.split(" ")
		cmd = inputs.shift()
		args = inputs.join " "
		if @listeners(cmd).length == 0
			if Interp.get('game').listeners(cmd).length == 0
				player.send "Invalid building command."
			else if @onGame(player, args, cmd)
				Interp.get('game').emit cmd, player, args, cmd
		else
			@emit cmd, player, args, cmd

	# Hook into game interp commands before they are sent
	# to the game interpreter. Return non true to
	# stop the game interpreter from reading the
	# input.
	onGame: (player, args, cmd) =>
		if cmd in @valid_dirs and not player.room.has_exit cmd
			@dig player, cmd
		return true

	prompt: (player) =>
		text = "{R"
		if player.get('autodig')
			text += "Autodig "
		text += "Building{x #{player.room.vars.name} (#{player.room.vars._x} #{player.room.vars._y} #{player.room.vars._z})>"
		player.sendRaw "\n\n#{text}"

	build: (player, args) =>
		player.set "building", false
		player.setInterp 'game'
		player.send "Building disabled."

	autodig: (player, args) =>
		if player.get('autodig')
			player.set('autodig', false)
			player.send "Autodig disabled."
		else
			player.set('autodig', true)
			player.send "Autodig enabled."

	dig: (player, args) =>
		if not args
			player.send "Usage: dig <direction>"
			return
		dir = args.split(' ')[0]

		if dir not in @valid_dirs
			player.send "Direction must be one of the following: #{@valid_dirs.join(', ')}"
			return
		
		if player.room.has_exit dir
			player.send "The current room already has an exit leading #{dir}."
			return

		new_room = new Room

		# This should always go last, so it populates/saves into the world after everything else is in place.
		new_room.set_coordinates player.room.get_neighbor_coord(dir)
		player.send "Room created #{dir}."

	set: (player, args) =>


module.exports = new Build