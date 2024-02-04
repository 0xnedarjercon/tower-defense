extends Node2D

@export var projectile: PackedScene
@export var range: float
@onready var collision_shape = $CollisionShape2D
var fire_interval
var fire_time
var target
var child_sprites = []
var rotators = []
var built = false
var mouse = 0

func _process(delta):
	if rotators.size()>0:
		mouse = get_viewport().get_mouse_position()
		var direction = position-get_viewport().get_mouse_position()
		for rotator in rotators:
			rotator.rotation = direction.angle()
	
func set_sprites(sprites, rotator_indices):
	for i in range(sprites.size()):
		var sprite = sprites[i]
		child_sprites.append(Sprite2D.new())
		child_sprites[-1].texture = sprite
		add_child(child_sprites[-1])
		if i in rotator_indices:
			rotators.append(child_sprites[-1])
		
func set_sprite_modulate(color):
	for sprite in child_sprites:
		sprite.modulate = color
		
func set_range(range):
	%CollisionShape2D.shape.radius = range
func build():
	built = true
	set_sprite_modulate(Color(1,1,1,1))
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#var current_time = Time.get_ticks_msec()
	#if fire_time < current_time:
		#target = find_target()
		#fire(target)


func find_target():
	var bodies = %Area2D.get_overlapping_bodies()
	var closest_target
	if bodies.size()>0:
		var targets = []
		for body in bodies:
			if body.has_method('target'):
				targets.append(body.target())
		var min_distance = range*range
		for target in targets:
			var distance = (target.position-position).length_squared()
			if distance < min_distance:
				closest_target = target
				min_distance = distance
	return closest_target
				
				
		
			
func fire(target):
	pass
	#var proj = projectile.instantiate()
	#add_child(proj)
	
func _on_area_entered(area):
	pass # Replace with function body.


func _on_area_exited(area):
	pass # Replace with function body.
