class Build extends Interp
	constructor: () ->
		@valid_dirs = ['north', 'n', 'east', 'e', 'south', 's', 'west', 'w', 'up', 'u', 'down', 'd']
		@on 'autodig', @autodig
		@on 'build', @build
		@on 'dig', @dig
		@on 'set', @set
		@on 'create', @create
		@on 'edit', @edit

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
		if cmd in @valid_dirs and not player.room.has_exit(cmd) and player.autodig
			@dig player, cmd
		return true

	prompt: (player) =>
		text = "{R"
		if player.autodig
			text += "Autodig "
		text += "Building{x #{player.room.vars.name} (#{player.room.vars._x} #{player.room.vars._y} #{player.room.vars._z})"
		if player.editing
			text += "\nEDITING: #{player.editing.get('name')} (#{player.editing.get('type')} #{player.editing.uuid()})"
		player.sendRaw "\n\n#{text}\n>"

	build: (player, args) =>
		player.set "building", false
		player.setInterp 'game'
		player.send "Building disabled."

	autodig: (player, args) =>
		if player.autodig
			player.autodig = false
			player.send "Autodig disabled."
		else
			player.autodig = true
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

	# Edit an entity.
	edit: (player, args) =>
		return player.send("Usage: edit <uuid/room>") if not args
		arg = args.split(' ')[0]
		switch arg
			when 'room'
				player.editing = player.room
			else
				e = Entity.lookup(arg)
				if not e
					return player.send("No such UUID found: #{arg}")
				else
					player.editing = e
		return player.send("Editing #{arg}")

	# Create a new object or NPC.
	create: (player, args) =>
		return player.send("Usage: create <npc/object>") if not args
		arg = args.split(' ')[0]
		switch arg
			when 'npc'
				npc = new NPC
				@edit player, npc.uuid()
			when 'object'
				player.send "Not yet"
			else
				player.send "Usage: create <npc/object>"
		return

	# Set a property of an entity.
	set: (player, args) =>
		return player.send("Not yet.")
module.exports = new Build