extends CharacterBody2D

@export var health: int

func _physics_process(delta):

	move_and_slide()
