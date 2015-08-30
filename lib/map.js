var Room = require('./room');

function Map(){
}

Map.generate = function(room, size, indent){
	indent = indent || 2;
	size = size || 5;
	if (!room)
		return "no map";
	var map_string = "\n";
	var base = room.get_coordinates();
	var start = [base[0] - size, base[1] + size, base[2]];
	for (var ny = start[1]; ny > base[1] - size; ny--){
		for (var nx = start[0]; nx < start[0] + (size * 2); nx++){
			if (nx == start[0]) {
				for (var i = 0; i < indent; i++){
					map_string += " ";
				}
			}
			var this_room = Room.exists([nx, ny, base[2]]);
			// TODO: Lookup of room type
			// TODO: make sure room is visible, no closed doors, etc.
			if (!this_room)
				map_string += " ";
			else if (this_room == room)
				map_string += "{R*{x";
			else
				map_string += "{W#{x";
		}
		map_string += "\n";
	}
	return map_string;
}
module.exports = Map;
