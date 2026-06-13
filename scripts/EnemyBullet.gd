extends Area2D

@export var speed := 800.0

func _process(delta):
	global_position.x -= speed * delta

	if global_position.x < -100:
		queue_free()

func _ready():
	add_to_group("enemy_bullets")