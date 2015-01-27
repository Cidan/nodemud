
function Color(){
}

Color.table = [
	{
		name: "clear",
		rx: new RegExp("{x", "g"),
		ansi: "[0m"
	},
	{
		name: "red",
		rx: new RegExp("{r", "g"),
		ansi: "[0;31m"
	},
	{
		name: "green",
		rx: new RegExp("{g", "g"),
		ansi: "[0;32m"
	},
	{
		name: "yellow",
		rx: new RegExp("{y", "g"),
		ansi: "[0;33m"
	},
	{
		name: "blue",
		rx: new RegExp("{b", "g"),
		ansi: "[0;34m"
	},
	{
		name: "magenta",
		rx: new RegExp("{m", "g"),
		ansi: "[0;35m"
	},
	{
		name: "cyan",
		rx: new RegExp("{c", "g"),
		ansi: "[0;36m"
	},
	{
		name: "white",
		rx: new RegExp("{w", "g"),
		ansi: "[0;37m"
	},
	{
		name: "dark grey",
		rx: new RegExp("{D", "g"),
		ansi: "[1;30m"
	},
	{
		name: "bright red",
		rx: new RegExp("{R", "g"),
		ansi: "[1;31m"
	},
	{
		name: "bright green",
		rx: new RegExp("{G", "g"),
		ansi: "[1;32m"
	},
	{
		name: "bright yellow",
		rx: new RegExp("{Y", "g"),
		ansi: "[1;33m"
	},
	{
		name: "bright blue",
		rx: new RegExp("{B", "g"),
		ansi: "[1;34m"
	},
	{
		name: "bright magenta",
		rx: new RegExp("{M", "g"),
		ansi: "[1;35m"
	},
	{
		name: "bright cyan",
		rx: new RegExp("{C", "g"),
		ansi: "[1;36m"
	},
	{
		name: "bright white",
		rx: new RegExp("{W", "g"),
		ansi: "[1;37m"
	}
]

String.prototype.color = function(strip){
	var str = this;
	for (var i in Color.table){
		var color = Color.table[i];
		if (strip)
			str = str.replace(color.rx, "");
		else
			str = str.replace(color.rx, color.ansi);
	}
	return str;
}

module.exports = Color;
