class Build extends Interp
	constructor: () ->
		@valid_dirs = ['north', 'east', 'south', 'west', 'up', 'down']
		@on 'build', @build
		@on 'dig', @dig

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
		return true

	prompt: (player) =>
		text = "{RBuilding{x #{player.room.vars.name} (#{player.room.vars._x} #{player.room.vars._y} #{player.room.vars._z})>"
		player.sendRaw "\n\n#{text}"

	build: (player, args) =>
		player.set "building", false
		player.setInterp 'game'
		player.send "Building disabled."

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
		new_room.set_name "New Room"
		new_room.set_description "This room is not yet rated."

		# This should always go last, so it populates/saves into the world after everything else is in place.
		new_room.set_coordinates player.room.get_neighbor_coord(dir)
		player.send "Room created #{dir}."


module.exports = new Build