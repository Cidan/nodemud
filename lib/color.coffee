Parser = require 'simple-text-parser'

class Color
	constructor: () ->
		@parser = new Parser
		@parser.addRule /\{./g, (color) ->
			color = color.substr(1)
			return "" if not Color.table[color]
			return Color.table[color].ansi

	parse: (str) =>
		return @parser.parse str

Color.table = {
	"x": 	{
		name: "clear",
		ansi: "[0m"
	},
	"u": {
		name: "underline",
		ansi: "[0;04m"
	},
	"r": {
		name: "red",
		ansi: "[0;31m"
	},
	"g": {
		name: "green",
		ansi: "[0;32m"
	},
	"y": {
		name: "yellow",
		ansi: "[0;33m"
	},
	"b": {
		name: "blue",
		ansi: "[0;34m"
	},
	"m": {
		name: "magenta",
		ansi: "[0;35m"
	},
	"c": {
		name: "cyan",
		ansi: "[0;36m"
	},
	"w": {
		name: "white",
		ansi: "[0;37m"
	},
	"D": {
		name: "dark grey",
		ansi: "[1;30m"
	},
	"R": {
		name: "bright red",
		ansi: "[1;31m"
	},
	"G": {
		name: "bright green",
		ansi: "[1;32m"
	},
	"Y": {
		name: "bright yellow",
		ansi: "[1;33m"
	},
	"B": {
		name: "bright blue",
		ansi: "[1;34m"
	},
	"M": {
		name: "bright magenta",
		ansi: "[1;35m"
	},
	"C": {
		name: "bright cyan",
		ansi: "[1;36m"
	},
	"W": {
		name: "bright white",
		ansi: "[1;37m"
	}
}

module.exports = (new Color).parse