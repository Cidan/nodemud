uuid = require 'uuid'
fs = require 'fs'

class Entity
	constructor: () ->
		# Semi static entity variables, name, description, etc.
		@vars = {}
		# Dynamic data, inventory, NPC's in room, etc
		@data = {}
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

	load: (opts, cb) =>
		return cb(new Error("No type set on this object")) if not @get('type')
		opts ?= {}
		opts.uuid ?= false
		hash = if opts.uuid then @uuid() else Common.hash(@get('name'), 'md5')
		filename = "#{config.get('data_dir')}#{@get('type')}/#{hash[0]}/#{hash[1]}/#{hash[2]}/#{hash}"
		fs.readFile filename, (err, saved_data) ->
			return cb(err) if err and cb
			cb null, JSON.parse(saved_data)

	save: (opts, cb) =>
		return cb(new Error("No type set on this object")) if not @get('type')
		return cb(new Error("Object is already saving")) if @_saving
		@_saving = true
		opts ?= {}
		opts.uuid ?= false
		hash = if opts.uuid then @uuid() else Common.hash(@get('name'), 'md5')
		filename = "#{config.get('data_dir')}#{@get('type')}/#{hash[0]}/#{hash[1]}/#{hash[2]}/#{hash}"
		fs.writeFile filename, JSON.stringify({
			vars: @vars,
			data: @data
		}), (err) =>
			@_saving = false
			log.debug("Error saving #{@uuid()}: #{err.message}") if err
			return cb(err) if err and cb
			log.debug "#{@uuid()} saved."
			cb(null) if cb

# Eventual globals
Entity._all = {}
Entity._indexes = {}

module.exports = Entity;
