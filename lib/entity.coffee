uuid = require 'uuid'

class Entity
	constructor: () ->
		@vars = {}
		@vars.uuid = uuid.v4()
		@vars.type = "entity"

	set: (k, v) =>
		@vars[k] = v

	get: (k) =>
		return @vars[k]

	uuid: () =>
		return @vars.uuid

	type: () =>
		return @vars.type

	set_name: (name) =>
		@set 'name', name

	get_name: () =>
		return @get 'name'

	set_description: (description) =>
		@set 'description_template', description
		@set 'description', editor.render(description)

	updateMetaData: () ->

# Eventual globals
Entity._all = {}
Entity._indexes = {}

module.exports = Entity;
