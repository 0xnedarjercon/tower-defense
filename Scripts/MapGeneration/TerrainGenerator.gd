


class_name TerrainGenerator
var tiles_per_chunk
var parameter_source
var algorithm
var empty_chunk = []
var loaded_tiles = {}
var p = Profiler.new(true)

func _init(_tiles_per_chunk, _parameter_source, _algorithm):
	algorithm = _algorithm
	tiles_per_chunk = _tiles_per_chunk
	parameter_source = _parameter_source
	for x in range(tiles_per_chunk):
		empty_chunk.append([])
		for y in range(tiles_per_chunk):
			empty_chunk[x].append(-1)
			
func get_chunks(chunk_batch):
	var new_chunks = []
	for chunk in chunk_batch:
		new_chunks.append(get_or_build_chunk(chunk))
	return new_chunks

func get_or_build_chunk(origin_position):
	if origin_position in loaded_tiles and loaded_tiles[origin_position][1][1] != -1:
		return self.loaded_tiles[origin_position]
	else:
		var top_position = Vector2i(origin_position[0], origin_position[1]-1)
		var left_position = Vector2i(origin_position[0]-1, origin_position[1])
		var top_left_position = Vector2i(origin_position[0]-1, origin_position[1]-1)
		loaded_tiles[origin_position] = get_or_init_tiles(origin_position)
		var top_and_left = get_top_left(top_left_position, top_position, left_position)
		build_map_chunk(loaded_tiles[origin_position] , origin_position, top_and_left[0], top_and_left[1])
		return loaded_tiles[origin_position]
	
func get_top_left(top_left_position, top_position, left_position):
		var top_chunk = get_or_init_tiles(top_position)
		var left_chunk = get_or_init_tiles(left_position)
		var top_left_chunk = get_or_init_tiles(top_left_position)
		var top = []
		var left = []
		if top_left_chunk[-1][-1] == -1:
			algorithm.generate_bottom_right_corner(top_left_position, parameter_source.get_params(top_left_position), top_left_chunk)
		top_chunk[0][-1] = top_left_chunk[-1][-1]  
		left_chunk[-1][0] = top_left_chunk[-1][-1]  
		if top_chunk[1][-1] == -1:
			if top_chunk[0][-1] == -1:
				var left_of_top_position = [top_position[0]-1, top_position[1]]
				var left_of_top_chunk = get_or_init_tiles(left_of_top_position)
				if left_of_top_chunk[-1][-1] == -1:
					algorithm.generate_bottom_right_corner(left_of_top_position, parameter_source.get_params(left_of_top_position), left_of_top_chunk)
				top_chunk[0][-1] = left_of_top_chunk[-1][-1]
			top = algorithm.generate_bottom(top_position, parameter_source.get_params(top_position), top_chunk)
		else:
			for row in top_chunk:
				top.append(row[-1])
		if left_chunk[-1][1] == -1:
			if left_chunk[-1][0] == -1:
				var top_of_left_position = [left_position[0], left_position[1]-1]
				var top_of_left_chunk = get_or_init_tiles(top_of_left_position)
				if top_of_left_chunk[-1][-1] == -1:
					algorithm.generate_bottom_right_corner(top_of_left_position, parameter_source.get_params(top_of_left_position), top_of_left_chunk)
				left_chunk[-1][0] = top_of_left_chunk[-1][-1]   
			left = algorithm.generate_right(left_position, parameter_source.get_params(left_position), left_chunk)
		else:
			left = left_chunk[-1].duplicate()
		return [top, left]

func get_or_init_tiles(chunk_position):
	if chunk_position not in loaded_tiles:
		loaded_tiles[chunk_position] =empty_chunk.duplicate(true)
	return self.loaded_tiles[chunk_position] 

func build_map_chunk(chunk,position, top, left):
	var offset_roughness_random_range = parameter_source.get_params(position)
	assign_top_left(chunk, top, left)
	algorithm.generate_bottom_right(chunk, position, offset_roughness_random_range)
	algorithm.generate(chunk, position , algorithm.tiles_per_chunk-1, offset_roughness_random_range)


func assign_top_left(tiles, top, left):
	tiles[0] = left.duplicate()
	for i in range(1, top.size()):
		tiles[i][0] = top[i]
	return self
	

	
