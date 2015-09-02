class Editor

	# Render a block of text, with options
	# and return the parsed text.
	render: (text, opts) ->
		return text

	# Add a line to the end of text.
	push_line: (text, line) ->
		return "#{text}\n#{line}"

	# Remove a line from the end of text.
	pop_line: (text, line) ->
		return text.substring(0, text.lastIndexOf('\n'))

	# Remove a line from the start of text.
	shift_line: (text, line) ->
		return text.substring(text.indexOf('\n') + 1);

	# Add a line to the start of text.
	unshift_line: (text, line) ->
		return "#{line}\n#{text}"

module.exports = new Editor