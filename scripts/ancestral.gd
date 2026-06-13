extends Area2D

@export var hp := 100
@export var bullet_scene: PackedScene
@export var fire_interval := 0.45
@export var wave_amplitude := 45.0
@export var wave_speed := 1.2
@onready var bullet_sound: AudioStreamPlayer2D = $"../BulletSound"

var dead := false
var start_y := 0.0
var wave_time := 0.0

func _ready():
	add_to_group("enemies")
	start_y = global_position.y
	shoot_loop()

func _process(delta):
	if dead:
		return

	wave_time += delta
	global_position.y = start_y + sin(wave_time * wave_speed) * wave_amplitude

func shoot_loop():
	while not dead:
		await get_tree().create_timer(fire_interval).timeout
		if not dead:
			shoot_volley()

func shoot_volley():
	var shot_offsets := [-120.0, -60.0, 0.0, 60.0, 120.0]
	bullet_sound.play()

	for index in shot_offsets.size():
		var bullet = bullet_scene.instantiate()
		var bullet_area := bullet.get_child(0) as Area2D
		if bullet_area != null:
			var vertical_spread := (index - 2) * 0.12
			bullet_area.set("direction", Vector2(-1.0, vertical_spread))

		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + Vector2(-330, shot_offsets[index])

func take_damage(amount := 1):
	if dead:
		return

	hp -= amount
	if hp <= 0:
		die()

func die():
	dead = true
	remove_from_group("enemies")
	queue_free()

func is_alive():
	return not dead
