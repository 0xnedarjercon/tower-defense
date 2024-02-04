

class_name DynamicParameterSource

var terrain_generator
var value_to_params
var source_chunks_per_tile
var tiles_per_chunk
var used_tiles_per_chunk
var parameter_source
var algorithm

func _init(_terrain_generator, _tiles_per_chunk, _parameter_source, _algorithm, _value_to_params, _source_chunks_per_tile):
	value_to_params = _value_to_params
	source_chunks_per_tile = _source_chunks_per_tile
	tiles_per_chunk = _tiles_per_chunk
	used_tiles_per_chunk = tiles_per_chunk-1
	parameter_source = _parameter_source
	algorithm = _algorithm
	terrain_generator = _terrain_generator

	
func get_params(position):
	var global_tile = floor(position/source_chunks_per_tile)
	var chunk = floor(global_tile/used_tiles_per_chunk)
	var local_tile = global_tile%used_tiles_per_chunk
	var tile_map = terrain_generator.get_or_build_chunk(chunk)
	var value = tile_map[local_tile.x][local_tile.y]
	var params = []
	for value_to_param in value_to_params:
		params.append(value_to_param[0] + (value - algorithm.min_value) * (value_to_param[1] - value_to_param[0]) / (algorithm.max_value - algorithm.min_value)	)
	return params


