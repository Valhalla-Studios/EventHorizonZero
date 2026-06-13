extends Node2D

@export var gheel_scene: PackedScene
@export var spawn_time := 1.5

var can_spawn := true

func _ready():
	spawn_loop()

func spawn_loop():
	while can_spawn:
		spawn_gheel()
		await get_tree().create_timer(spawn_time).timeout

func spawn_gheel():
	var enemy = gheel_scene.instantiate()

	enemy.global_position = Vector2(
		2050,
		randf_range(120, 960)
	)

	get_tree().current_scene.call_deferred("add_child", enemy)

	enemy.global_position = Vector2(
		2050,
		randf_range(120, 960)
	)


func stop_spawning():
	can_spawn = false