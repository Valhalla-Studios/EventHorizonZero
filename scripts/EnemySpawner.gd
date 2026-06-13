extends Node2D

@export var gheel_scene: PackedScene
@export var veyl_scene: PackedScene
@export var spawn_time := 1.5
@export var veyl_spawn_delay := 30.0
@export var veyl_spawn_time := 8.0

const GHEEL_VERTICAL_MARGIN := 145.0
const VEYL_VERTICAL_MARGIN := 64.0

var can_spawn := true

func _ready():
	spawn_loop()
	veyl_spawn_loop()

func spawn_loop():
	while can_spawn:
		spawn_gheel()
		await get_tree().create_timer(spawn_time).timeout

func spawn_gheel():
	spawn_enemy(gheel_scene, GHEEL_VERTICAL_MARGIN)
	spawn_enemy(gheel_scene, GHEEL_VERTICAL_MARGIN)

func veyl_spawn_loop():
	await get_tree().create_timer(veyl_spawn_delay).timeout

	while can_spawn:
		spawn_enemy(veyl_scene, VEYL_VERTICAL_MARGIN)
		await get_tree().create_timer(veyl_spawn_time).timeout

func spawn_enemy(enemy_scene: PackedScene, vertical_margin: float):
	if enemy_scene == null:
		return

	var viewport_height := get_viewport_rect().size.y
	var enemy = enemy_scene.instantiate()
	enemy.global_position = Vector2(
		2050,
		randf_range(vertical_margin, viewport_height - vertical_margin)
	)
	get_tree().current_scene.call_deferred("add_child", enemy)

func stop_spawning():
	can_spawn = false
