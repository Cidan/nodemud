uuid = require 'uuid'
events = require 'events'

class Entity extends events.EventEmitter
	constructor: () ->
		@vars = {}
		@vars.uuid = uuid.v4()
		@vars.type = "entity"
		@contains = {}

	set: (k, v) =>
		@vars[k] = v

	get: (k) =>
		return @vars[k]

	uuid: () =>
		return @vars.uuid

	type: () =>
		return @vars.type
	
	add_entity: (obj) =>
		return false if not obj.type()
		@contains[obj.type()] ?= {}
		@contains[obj.type()][obj.uuid()] = obj
		@emit 'add_entity', {
			added: obj,
			target: this
		}
	
	remove_entity: (obj) =>
		return false if not obj.type()
		@contains[obj.type()] ?= {}
		delete @contains[obj.type()][obj.uuid()]
		@emit 'remove_entity', {
			removed: obj,
			target: this
		}

	has_entity: (obj) =>
		return false if not obj.type()
		@contrains[obj.type()] ?= {}
		return @contrains[obj.type()][obj.uuid()]

	updateMetaData: () ->
# Eventual globals
Entity._all = {}
Entity._indexes = {}

module.exports = Entity;
