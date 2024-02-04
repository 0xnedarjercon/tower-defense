extends TileMap
#const ParameterSource = preload("res://Scripts/ParameterSource.gd")
#const TerrainGenerator = preload("res://Scripts/TerrainGenerator.gd")

# _init(_tiles_per_chunk, _parameter_source, _algorithm):
#var algo = DaimondSquareAlgorithm.new()
#var static_params = ParameterSource
#var terrain_generator = TerrainGenerator.new()
# Called when the node enters the scene tree for the first time.
var p = Profiler.new(false)
var tiles_per_chunk=65
var shown_tiles_per_chunk = tiles_per_chunk-1
var algo
var static_params
var terrain_generator
var atlas_chunks = {}
var blank_atlas_chunk = []
var max_path_length = 65
var points = []
var index = 0
var terrained_chunks = []
var pixels = tile_set.tile_size.x
var draw_grid = false
var thresholds = [40, 81,120, 160, 204, 245, 256]
var moisture_thresholds = [80, 204,256]
var tile_mode = true
@onready var camera_offset = floor((get_viewport().get_visible_rect().size)/2)
					# water, sand, dirt, grass, snow
var terrain_params = [Vector3i(0,0,1), Vector3i(0,0,2),Vector3i(0,0,0), Vector3i(0,0,20), Vector3i(0,0,15)]
var id = 2
@onready var z = get_node("/root/Node2D/z")
@onready var root = get_node('/root/Node2D/')
@onready var camera = get_node('/root/Node2D/Camera2D')
var preload_distance = 2
var prev_camera_chunk = Vector2i(0, 0)
var image = Image.new()
var moisture_generator
var dynamic_paramater_source

func _ready():
	for i in range(shown_tiles_per_chunk):
		blank_atlas_chunk.append([])
		for j in range(shown_tiles_per_chunk):
			blank_atlas_chunk[i].append(0)
	var macro_tiles_per_chunk = 33
	var macro_algo = DaimondSquare.new(macro_tiles_per_chunk, 0, 255, 'macro')
	static_params = StaticParameterSource.new([50, 0.1, 127])
	var macro_terrain_generator = TerrainGenerator.new(macro_tiles_per_chunk, static_params, macro_algo)
	var _value_to_params = [[30,155], [0.1,0.8], [50, 100]]
	var source_chunks_per_tile = 10
	dynamic_paramater_source = DynamicParameterSource.new(macro_terrain_generator, macro_tiles_per_chunk,static_params,macro_algo, _value_to_params,source_chunks_per_tile )
	algo= DaimondSquare.new(tiles_per_chunk, 0, 255, 'base')
	var moisture_algo = DaimondSquare.new(tiles_per_chunk, 0, 255, 'moisture')
	terrain_generator = TerrainGenerator.new(tiles_per_chunk, dynamic_paramater_source, algo)
	moisture_generator = TerrainGenerator.new(tiles_per_chunk, dynamic_paramater_source, moisture_algo)
	var camera_chunk =Vector2i(floor(camera.position.x/(shown_tiles_per_chunk*pixels)),floor(camera.position.y/(shown_tiles_per_chunk*pixels)))
	update_chunks(camera_chunk)
	
func update_chunks(camera_chunk):
	var needed_chunks = get_tile_chunks(camera_chunk)
	needed_chunks = remove_terrains(needed_chunks)
	var heights = terrain_generator.get_chunks(needed_chunks)
	var moistures = moisture_generator.get_chunks(needed_chunks)
	update_terrain(needed_chunks, heights, moistures)
	
func get_tile_chunks(camera_chunk):
	var needed_chunks = []
	for i in range(camera_chunk.x - preload_distance, camera_chunk.x + preload_distance):
		for j in range(camera_chunk.y-preload_distance, camera_chunk.y+preload_distance):
			var pos = Vector2i(i,j)
			needed_chunks.append(pos)
	return needed_chunks


func update_terrain(origins, heights, moistures):
	for i in range(origins.size()):
		if origins[i] not in terrained_chunks:
			terrained_chunks.append(origins[i])
			if tile_mode:
				for x in range(shown_tiles_per_chunk):
					for y in range(shown_tiles_per_chunk):
						var atlas_coords = get_atlas_coords(heights[i][x][y], moistures[i][x][y])
						set_cell(0, Vector2i(origins[i][0]*(shown_tiles_per_chunk)+x, origins[i][1]*(shown_tiles_per_chunk)+y), id, atlas_coords)
			else:
				var new_tiles = z.duplicate()
				add_child(new_tiles)
				new_tiles.position.x = origins[i][0]*(shown_tiles_per_chunk)*pixels
				new_tiles.position.y = origins[i][1]*(shown_tiles_per_chunk)*pixels
				new_tiles.set_sprite(heights, pixels)
				
func get_atlas_coords(height, moisture):
	var height_index=-1
	var moisture_index=-1
	for i in range(thresholds.size()):
		if height< thresholds[i]:
			height_index = i
			break
	for i in range(moisture_thresholds.size()):
		if moisture< moisture_thresholds[i]:
			moisture_index = i
			break
	return Vector2i(moisture_index, height_index)
	
func remove_terrains(needed_chunks):

	var removal_indexes = []
	for i in range(terrained_chunks.size()):
		if terrained_chunks[i] not in needed_chunks:
			removal_indexes.append(i)
			for x in range(1, tiles_per_chunk):
				for y in range(1, tiles_per_chunk):
					var coord = Vector2i(terrained_chunks[i].x*(shown_tiles_per_chunk)+x, terrained_chunks[i].y*(shown_tiles_per_chunk)+y)
					erase_cell(0, coord)
	var remove_count = removal_indexes.size()
	for i in range(remove_count):
		terrained_chunks.remove_at(removal_indexes[remove_count-i-1])
	return needed_chunks
	
		
 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var camera_chunk =Vector2i(floor(camera.position.x/(shown_tiles_per_chunk*tile_set.tile_size.x)),floor(camera.position.y/(shown_tiles_per_chunk*tile_set.tile_size.y)))
	if camera_chunk != prev_camera_chunk:
		update_chunks(camera_chunk)


func get_height(coords):
	return terrain_generator.loaded_tiles[coords[0]][coords[1].x][coords[1].y]
	
func get_moisture(coords):
	return moisture_generator.loaded_tiles[coords[0]][coords[1].x][coords[1].y]
	
func world_to_tile(raw_position):
	var global_tile = world_to_map(raw_position)
	var chunk_coord = Vector2i(floor(float(global_tile)/(shown_tiles_per_chunk)))
	var local_coord = (global_tile)%(shown_tiles_per_chunk)
	if local_coord.x <0:
		local_coord.x += shown_tiles_per_chunk
	if local_coord.y <0:
		local_coord.y += shown_tiles_per_chunk
	return [chunk_coord, local_coord]
	
func world_to_map(raw_position):
	var adjusted_position = (raw_position-camera_offset)/camera.zoom + camera.position
	return local_to_map(adjusted_position)

func get_atlas(raw_position):
	return get_cell_atlas_coords(0, (world_to_map(raw_position)))
	
	
func generate_paths(start):
	var start_chunk_coord = Vector2i(floor(float(start)/(shown_tiles_per_chunk)))
	var start_local_coord = (start)%(shown_tiles_per_chunk)
	generate_path(start_chunk_coord, start_local_coord)
	
func generate_path(start_chunk_coord, start_local_coord):
	var found = false
	var current_chunk = start_chunk_coord
	var start_position = start_local_coord
	while not found:
		pass
	
	
func _input(event):
	pass
   # Mouse in viewport coordinates.
	#if event is InputEventMouseButton and event.button_index == 1 and event.pressed == true:
		#var coords = world_to_tile(event.position)
		#var tile_value_grid_position_tile_position = get_tile(local_to_map(event.position))
		#print('value: ',tile_value_grid_position_tile_position[0])
		#print('grid: ',tile_value_grid_position_tile_position[1])
		#print('tile: ',tile_value_grid_position_tile_position[2])
		#if tile_value_grid_position_tile_position[1] in terrained_chunks:
			#print(true)
		#else:
			#print(false)
		






