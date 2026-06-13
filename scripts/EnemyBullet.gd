extends Area2D

@export var speed := 500.0
@export var direction := Vector2.LEFT

func _ready():
	add_to_group("enemy_bullets")
	area_entered.connect(_on_area_entered)
	direction = direction.normalized()
	rotation = direction.angle()

func _process(delta):
	global_position += direction * speed * delta

	if global_position.x < -100 or global_position.x > 2020:
		queue_free()

	if global_position.y < -100 or global_position.y > 1180:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("player"):
		queue_free()
