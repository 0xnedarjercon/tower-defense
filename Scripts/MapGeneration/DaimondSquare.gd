

class_name DaimondSquare
var min_value: int
var max_value: int
var tiles_per_chunk:int
var modifier = ''
var min_random_range = 0
var size_threshold = 33
func _init(_tiles_per_chunk, _min_value, _max_value, _modifier):
	min_value = _min_value
	max_value = _max_value
	tiles_per_chunk = _tiles_per_chunk
	modifier = _modifier
	
func generate(tiles, origin, size, offset_roughness_random_range, x_local = 0, y_local = 0):
	if size <2:
		return tiles
	var half_size = floor(size/2)
	var avg = (tiles[x_local][y_local] + tiles[x_local][y_local + size] + tiles[x_local + size][y_local] + tiles[x_local + size][y_local + size]) / 4
	tiles[x_local+half_size][y_local+half_size] = randomise(avg, 
	[x_local+half_size+origin[0],y_local+half_size+origin[1]], offset_roughness_random_range[2])
	if x_local != 0:
		avg = (tiles[x_local][y_local] + tiles[x_local][y_local+size]) / 2
		tiles[x_local][y_local+half_size] = randomise(avg, 
	[x_local+origin[0],y_local+half_size+origin[1]], offset_roughness_random_range[2])
	if y_local != 0:
		avg = (tiles[x_local][y_local] + tiles[x_local+size][y_local]) / 2
		tiles[x_local + half_size][y_local] = randomise(avg, [origin[0] + x_local+half_size, origin[1] + y_local], offset_roughness_random_range[2])
	if x_local + size != tiles_per_chunk-1:
		avg = (tiles[x_local+size][y_local] + tiles[x_local + size][y_local + size]) / 2
		tiles[x_local + size][y_local + half_size] = randomise(avg, [origin[0] + x_local+size, origin[1] + y_local+half_size], offset_roughness_random_range[2])
	# Bottom
	if y_local + size != tiles_per_chunk-1:
		avg = (tiles[x_local][y_local+size] + tiles[x_local + size][y_local + size]) / 2
		tiles[x_local + half_size][y_local + size] = randomise(avg, [origin[0] + x_local+half_size, origin[1] + y_local+size,], offset_roughness_random_range[2])
	var next_offset_roughness_random_range
	if size < size_threshold:
		next_offset_roughness_random_range = [offset_roughness_random_range[0],offset_roughness_random_range[1], 
	max(offset_roughness_random_range[1]*offset_roughness_random_range[2], min_random_range)]
	else:
		next_offset_roughness_random_range =offset_roughness_random_range
	generate(tiles, origin, half_size,  next_offset_roughness_random_range.duplicate(), x_local, y_local)
	generate(tiles, origin, half_size,  next_offset_roughness_random_range.duplicate(), x_local + half_size, y_local)
	generate(tiles, origin, half_size,  next_offset_roughness_random_range.duplicate(), x_local, y_local + half_size)
	generate(tiles, origin, half_size,  next_offset_roughness_random_range.duplicate(), x_local + half_size, y_local + half_size)
	
func generate_bottom_right( tile_map, chunk_position,offset_roughness_random_range):
	var tile_x = (chunk_position[0])*tiles_per_chunk
	var tile_y = (chunk_position[1])*tiles_per_chunk
	tile_map[-1][-1] = get_corner([chunk_position[0]+0.5, chunk_position[1]+0.5], offset_roughness_random_range[2], offset_roughness_random_range[0])
	var blank_row = []
	blank_row.resize(tiles_per_chunk)
	blank_row.fill(-1)
	bottom_displace(tile_x, tile_y, tile_map, tiles_per_chunk-1, offset_roughness_random_range,  blank_row.duplicate(true),0 )
	right_displace(tile_x, tile_y, tile_map, tiles_per_chunk-1, offset_roughness_random_range,  blank_row, 0 )
	return tile_map
func generate_bottom(chunk_position,offset_roughness_random_range, tile_map):
	var tile_x = chunk_position[0]*tiles_per_chunk
	var tile_y = (chunk_position[1])*tiles_per_chunk
	tile_map[-1][-1] = get_corner([chunk_position[0]+0.5, chunk_position[1]+0.5], offset_roughness_random_range[2], offset_roughness_random_range[0])
	var bottom_cells = Array()
	bottom_cells.resize(tiles_per_chunk)
	bottom_cells.fill(-1)
	bottom_cells[0] = tile_map[0][-1]
	bottom_cells[-1] = tile_map[-1][-1]
	return bottom_displace(tile_x, tile_y, tile_map, tiles_per_chunk-1, offset_roughness_random_range, bottom_cells, 0)

func bottom_displace(x_origin, y_origin, tiles, size, offset_roughness_random_range,  bottom_cells, x_local = 0 ):
	if size <2:
		return bottom_cells
	var half_size= size/2   
	var avg = (tiles[x_local][-1]+ tiles[x_local+size][-1]) / 2   
	var value = randomise(avg, [x_origin + x_local+half_size, y_origin + -1], offset_roughness_random_range[2])
	bottom_cells[x_local + half_size] = value
	var next_offset_roughness_random_range = [offset_roughness_random_range[0], offset_roughness_random_range[1], offset_roughness_random_range[1]*offset_roughness_random_range[2]]
	tiles[x_local + half_size][-1] = value
	bottom_displace(x_origin, y_origin, tiles, half_size, next_offset_roughness_random_range.duplicate(),bottom_cells, x_local)
	bottom_displace(x_origin, y_origin, tiles, half_size, next_offset_roughness_random_range, bottom_cells, x_local+half_size)
	return bottom_cells

func generate_right(chunk_position,next_offset_roughness_random_range, tile_map):
	var tile_x = (chunk_position[0])*tiles_per_chunk
	var tile_y = (chunk_position[1])*tiles_per_chunk
	if tile_map[-1][-1] == -1:
		tile_map[-1][-1] = get_corner([chunk_position[0]+0.5, chunk_position[1]+0.5], next_offset_roughness_random_range[2], next_offset_roughness_random_range[0])
	var right_cells = Array()
	right_cells.resize(tiles_per_chunk)
	right_cells.fill(-1)
	right_cells[0] = tile_map[-1][0]
	right_cells[-1] = tile_map[-1][-1]
	return self.right_displace(tile_x, tile_y, tile_map, self.tiles_per_chunk-1, next_offset_roughness_random_range, right_cells)

func right_displace( x_origin, y_origin, tiles, size, offset_roughness_random_range, right_cells, y_local = 0):
	if size <2:
		return tiles
	var half_size= size/2
	#right
	var avg = (tiles[-1][y_local] + tiles[-1][y_local+size]) / 2
	var value = randomise(avg, [x_origin + tiles_per_chunk-1, y_origin + y_local+half_size], offset_roughness_random_range[2])
	tiles[-1][y_local + half_size] = value
	right_cells[y_local + half_size] = value
	var next_offset_roughness_random_range = [offset_roughness_random_range[0], offset_roughness_random_range[1], offset_roughness_random_range[1]*offset_roughness_random_range[2]]
	right_displace(x_origin, y_origin, tiles, half_size,  next_offset_roughness_random_range, right_cells, y_local)
	right_displace(x_origin, y_origin, tiles, half_size,  next_offset_roughness_random_range, right_cells, y_local+half_size)
	return right_cells
	
	
func generate_bottom_right_corner( chunk_position, offset_roughness_random_range, tile_map):
	var corner = get_corner([chunk_position[0]+0.5, chunk_position[1]+0.5], offset_roughness_random_range[2], offset_roughness_random_range[0])
	tile_map[-1][-1] = corner
	return corner
	
func get_corner(_seed, _range, offset):
	return clamp((rng.rand_float([modifier]+_seed)*_range+offset), min_value, max_value)  
func randomise(value, _seed, random_magnitude):
	return clamp(value +(rng.rand_float([modifier]+_seed)-0.5)*2*random_magnitude, min_value, max_value)
	

