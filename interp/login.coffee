class Login extends Interp
	constructor: (player) ->

	onLoad: (player) =>
		player.state = 'GET_NAME'
		player.send "By what name do you wish to be known?", false

	isValidName: (name) =>
		if name is ""
			return false
		return true

	show_passwordHelp: (player) =>
		player.buffer "\nA note on passwords:", true
		player.buffer " Passwords are never stored in plain text, and", true
		player.buffer " are hashed with the SHA512 hash scheme.", true
		player.buffer " Immortals and Administrators do not have", true
		player.buffer " access to your password and can not tell you", true
		player.buffer " or anyone else what it is.\n", true
		player.buffer " That being said, this MUD does not use", true
		player.buffer " SSL/TLS for communication encryption. You", true
		player.buffer " should not use the same password as you do for", true
		player.buffer " your e-mail, etc.", true
		player.buffer "\n\n tl;dr, {RUse a secret, but throw-away password.{x\n\n", true
		player.flush()
		player.send "Give me a password for #{player.get 'name'}:"

	handle_GetName: (player, name) =>
		if not @isValidName(name)
			player.send "I'm sorry, that's not a valid name.", true
			player.send "Let's try this again, what name shall you go by?"
			return
		player.set 'name', name
		player.load (err, data) =>
			if not err
				player.set 'tmp_player', data
				player.send "Password:"
				player.state = 'OLD_PASSWORD'
				return
			player.send "Did I get that right, #{name}?"
			player.state = 'CONFIRM_NAME'

	handle_ConfirmName: (player, resp) =>
		if Common.isYes(resp)
			@show_passwordHelp(player)
			player.state = 'NEW_PASSWORD'
		else
			player.set 'name', ''
			player.send "Okay, what is it then?"
			player.state = 'GET_NAME'

	handle_NewPassword: (player, pwd) =>
		player.set 'password', Common.hash(pwd)
		player.send "Retype your password to confirm:"
		player.state = 'CONFIRM_PASSWORD'

	handle_ConfirmPassword: (player, pwd) =>
		if player.get('password') != Common.hash(pwd)
			player.send "The passwords you entered did not match. Let's start over.", true
			player.send "Give me a password for #{@player.get 'name'}:"
			player.state = 'NEW_PASSWORD'
		else
			player.send "Logging you in!"
			player.to_room [0,0,0]
			player.setInterp 'game'
			player.parse 'look'
			player.save()

	handle_OldPassword: (player, pwd) =>
		new_hash = Common.hash pwd
		old_hash = player.get('tmp_player').vars.password
		if old_hash != new_hash
			player.send "Wrong password. See ya."
			player.disconnect()
			player.cleanup()
			return

		player.loadFromData player.get('tmp_player')
		player.send "Welcome back!", true
		player.setInterp 'game'
		player.to_room player.get('room')
		player.parse 'look'

	parse: (player, line) =>
		switch player.state
			when 'GET_NAME'
				@handle_GetName player, line
			when 'CONFIRM_NAME'
				@handle_ConfirmName player, line
			when 'NEW_PASSWORD'
				@handle_NewPassword player, line
			when 'CONFIRM_PASSWORD'
				@handle_ConfirmPassword player, line
			when 'OLD_PASSWORD'
				@handle_OldPassword player, line

module.exports = new Login