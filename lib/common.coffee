crypto = require 'crypto'
mkdirp = require 'mkdirp'

module.exports.isYes = (line) ->
	if line.toLowerCase() == "yes" or line.substring(0,1).toLowerCase() == "y"
		return true
	return false

module.exports.isAlpha = (text) ->
	if text.match /[a-zA-Z]+/
		return true
	return false

module.exports.hash = (text, hash) ->
	hash = hash || "sha512"
	return crypto.createHash(hash).update(text).digest('hex')

module.exports.make_hash_dir = (path, level) ->
	self = this
	hash_map = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'a', 'b', 'c', 'd', 'e', 'f']
	hash_map.forEach (i) ->
		mkdirp.sync path + "/" + i
		if level > 1
			self.make_hash_dir path + "/" + i, level - 1

String.prototype.capitalize = () ->
	return this.charAt(0).toUpperCase() + this.slice(1)

String.prototype.isAlpha = () ->
	Common.isAlpha(this)