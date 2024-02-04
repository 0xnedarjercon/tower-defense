extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
var speed =1000
var zoom_speed: float = 0.1
var min_zoom: float = 0.5
var max_zoom: float = 4.0
var up_down = 0
var left_right = 0
var mouse_wheel = 0
#
#func _input(event):
	#if event is InputEventMouseButton:
		#
func _process(delta):
	# Get the input vector based on arrow keys
	var input_vector = Vector2()

	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	# Check for mouse wheel input
	if Input.is_action_just_released("mouse_wheel_up"):
		zoom_in()
	elif Input.is_action_just_released("mouse_wheel_down"):
		zoom_out()
	input_vector = input_vector.normalized()

	# Move the camera
	position += input_vector * speed * delta

func zoom_in():
	zoom.x += zoom_speed
	zoom.y +=zoom_speed
	# Clamp the zoom value to stay within the specified range
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)

func zoom_out():
	zoom.x -= zoom_speed
	zoom.y -=zoom_speed
	# Clamp the zoom value to stay within the specified range
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)

	# Normalize the vector to ensure consistent movement speed in all directions

