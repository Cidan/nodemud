Entity = require './entity'

class NPC extends Entity
	constructor: () ->
		super
		@set 'type', 'npc'
		# TODO: register in global NPC table?
		@register()

NPC.init = (cb) ->
	log.info "Making NPC hash directories"
	Common.make_hash_dir "#{config.get('data_dir')}npc/", 3
	cb()

module.exports = NPC