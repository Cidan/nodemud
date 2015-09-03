Entity = require './entity'

class NPC extends Entity
	constructor: () ->
		super
		@set 'type', 'npc'

module.exports = NPC