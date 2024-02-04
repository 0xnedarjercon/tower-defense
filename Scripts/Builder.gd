extends Sprite2D

var placed = false
@onready var screen_offset = floor((get_viewport().get_visible_rect().size)/2)
@onready var camera = get_node('/root/Node2D/Camera2D')
@onready var world_map = get_node('/root/Node2D/TileMap')
const build_panel_scene = preload('res://Scenes/build_panel.tscn')
const texture_button_scene = preload('res://Scenes/texture_wall_button.tscn')
var anthill = preload("res://Sprites/anthill.png")
var wall_image = preload("res://Sprites/wall.png").get_image()



var available_buildings = {'base':{'sprites': [anthill], 'footprint': [Vector2i(0,0)], 'rotators': [], 'keep': false}, 
							'wall':{'sprites': [preload("res://Sprites/wall.png")], 'footprint': [Vector2i(0,0)],'rotators': [], 'keep': true }, 
							'turret1':{'sprites': [preload("res://Sprites/wall.png"), preload("res://Sprites/turret1.png")], 'footprint': [Vector2i(0,0)], 'rotators': [1], 'keep': true},
							'turret2':{'sprites': [preload("res://Sprites/wall.png"), preload("res://Sprites/turret2.png")], 'footprint': [Vector2i(0,0)], 'rotators': [1], 'keep': true}}

var blueprint_data = null
var build_count = 0
var current_blueprint
var blueprint_scene = preload("res://Scenes/building_blueprint.tscn")
var building_scene = preload("res://Scenes/building.tscn")
const buy_button_scene = preload("res://Scenes/buy_button.tscn")
var buildable_heights = [3,4]
var build_panel = null
# Called when the node enters the scene tree for the first time.
var buttons = []
var walls = []
var current_footprint = []

func clear_blueprint():
	current_blueprint.queue_free()
	current_footprint = null
	
func create_blueprint(_building_data):
	current_blueprint = building_scene.instantiate()
	current_blueprint.set_sprites(_building_data['sprites'], _building_data['rotators'])
	current_footprint = _building_data['footprint']
	add_child(current_blueprint)
	blueprint_data = _building_data
	

	
func create_button(name):
	buy_button_scene.instantiate()
	
func build(pos):
	var building = building_scene.instantiate()
	add_child(building)
	building.position = pos
	building.texture = blueprint_data['sprite']
	current_blueprint.queue_free()
	current_blueprint = null

func _ready():
	wall_image.convert(Image.FORMAT_RGBA8)
	create_blueprint(available_buildings['base'])
	init()



func init():
	for building in available_buildings.values():
		init_button(building)
		
func init_button(building):
	var button = buy_button_scene.instantiate()
	%HBoxContainer.add_child(button)
	button.texture_normal = building['sprites'][-1]
	button.pressed.connect(create_blueprint.bind(building))
	
	
	
func can_build(position):
	for tile in current_footprint:
		if world_map.get_atlas(position)[1] not in buildable_heights:
			return false
	return true
	
func _input(event):
	if current_blueprint!= null:
		if (event is InputEventMouseMotion or event is InputEventMouseButton and event.button_index == 5):
			current_blueprint.position = snap_to_tile(((event.position-screen_offset)/camera.zoom+camera.position))-position
			if can_build(event.position):
				current_blueprint.set_sprite_modulate(Color(0,0.5,0,0.5))
			else:
				current_blueprint.set_sprite_modulate(Color(0.5,0,0,0.5))
		elif event is InputEventMouseButton and event.button_index == 1:
			if can_build(event.position):
				current_blueprint.position = snap_to_tile(((event.position-screen_offset)/camera.zoom+camera.position))-position
				current_blueprint.build()
				clear_blueprint()
				if blueprint_data['keep']:
					create_blueprint(blueprint_data)
		elif event is InputEventMouseButton and event.button_index == 2:
			clear_blueprint()

				
func initialise_build():
	for button in buttons:
		button.queue_free()
	buttons = []
	walls = []
	for i in range(5):
		var button = texture_button_scene.instantiate()
		buttons.append(button)
		var button_image = button.texture_normal.get_image()
		var wall_coords = generate_random_walls(str(build_count))
		walls.append(wall_coords)
		for coord in wall_coords:
			button_image.blit_rect(wall_image, Rect2i(0,0,32,32), Vector2i(coord.x*32, coord.y*32))
		
		button.texture_normal= ImageTexture.create_from_image(button_image)
		button.pressed.connect(wall_pressed.bind(i))
		%HBoxContainer.add_child(button)
		build_count+=1
		#buildings['wall'+str(i)] = {'sprite' : button.texture_normal, 'footprint':wall_coords}
		
func generate_random_walls(seed):
	var coords = []
	var x = rng.rand_int(seed+'x'+str(build_count), 0,3)
	var y = rng.rand_int(seed+'y'+str(build_count), 0,3)
	coords.append(Vector2i(x,y))
	for i in range(2):
		x = clamp(x+rng.rand_int(seed+'x_o' +str(i), -1,1), 0,3)
		var pos = Vector2i(x,y)
		if pos not in coords:
			coords.append(Vector2i(x,y))
		y = clamp(rng.rand_int(seed+'y_o'+str(i), -1,1)+y,0,3)
		pos = Vector2i(x,y)
		if pos not in coords:
			coords.append(Vector2i(x,y))
	return coords
	
func wall_pressed(index):
	var button = buttons[index]
	var wall = walls[index]
	create_blueprint('wall'+str(index))
	current_blueprint = blueprint_scene.instantiate()
	current_blueprint.initialise(button.texture_normal, camera, screen_offset, buildable_heights, world_map)
	
func snap_to_tile(position):
	return floor(position/ world_map.tile_set.tile_size.x)*world_map.tile_set.tile_size.x+Vector2(16,16)

