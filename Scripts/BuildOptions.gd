extends CanvasLayer
var button_scene = preload('res://Scenes/texture_wall_button.tscn')
@export var num_options = 5
@export var item_range = [3,5]
var blank_coords = []

func _ready():
	for i in range(4):
		blank_coords.append([])
		for j in range(4):
			blank_coords[i].append(0)
# Called when the node enters the scene tree for the first time.
func generate_walls():
	for i in range(num_options):
		var button = button_scene.instantiate()
		%HBoxContainer.add_child(button)
		

	
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
