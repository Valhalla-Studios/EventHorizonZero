extends Area2D

@export var speed := 1800.0
@export var damage := 1

func _ready():
	area_entered.connect(_on_area_entered)

func _process(delta):
	global_position.x += speed * delta

	if global_position.x > 2200:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("enemies"):
		if area.has_method("take_damage"):
			area.take_damage(damage)

		queue_free()