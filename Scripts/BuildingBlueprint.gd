extends Area2D

var camera
var screen_offset
var buildable_heights
var buildable = false
var world_map
var built = false
@onready var sprite = %Sprite2D
func initialise(_sprite):
	sprite.texture = _sprite


func build():
	built = true
	sprite.modulate=Color(1,1,1,1)
	
func snap_to_tile(position):
	return floor(position/ world_map.tile_set.tile_size.x)*world_map.tile_set.tile_size.x+Vector2(16,16)
