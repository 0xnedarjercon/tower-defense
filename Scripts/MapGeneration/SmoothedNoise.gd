

class_name SmoothedNoise
	
var tiles_per_chunk:int
var min_value: int
var max_value: int
var modifier = ''


func _init(_tiles_per_chunk, _min_value, _max_value, _modifier):
	min_value = _min_value
	max_value = _max_value
	tiles_per_chunk = _tiles_per_chunk
	modifier = _modifier


func generate(tiles, origin, size, offset_roughness_random_range):
	tiles[0][0] = rng.rand_float([modifier]+[origin[0],origin[1]])*max_value-min_value+min_value
	tiles[0][-1] = rng.rand_float([modifier]+[origin[0],origin[1]])*max_value-min_value+min_value
	
func generate_bottom_right( tile_map, chunk_position,offset_roughness_random_range, return_bottom = false):
	pass
func generate_bottom(chunk_position,offset_roughness_random_range, tile_map):
	pass

func bottom_displace(x_origin, y_origin, tiles, size, offset_roughness_random_range,  bottom_cells, x_local = 0 ):
	pass
func generate_right(chunk_position,next_offset_roughness_random_range, tile_map):
	pass
func right_displace( x_origin, y_origin, tiles, size, offset_roughness_random_range, right_cells, y_local = 0):
	pass
func randomise(value, seed, random_magnitude):
	return clamp(value +(rng.rand_float([modifier]+seed)-0.5)*2*random_magnitude, min_value, max_value)
