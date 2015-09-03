class CLI
	constructor: () ->
		@vantage = new (require 'vantage')

	init: (cb) =>
		log.info "Loading CLI..."
		@vantage
			.delimiter('mud> ')
			.show()

		@register {
			command: "show <type>",
			action: @show,
			description: "Show all objects/players/NPC's of a given type."
		}
		cb()

	register: (opts) =>
		return if not opts or not opts.command or not opts.action
		@vantage
			.command opts.command
			.action opts.action
			.description opts.description

	show: (args, cb) ->
		@log "Nothing yet."
		cb()
module.exports = new CLI