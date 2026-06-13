extends Area2D

@export var speed := 150.0
@export var hp := 3
@export var element_n_scene: PackedScene
@export var element_n_drop_chance := 0.50
@export var bullet_scene: PackedScene
@export var fire_interval := 1.0
@export var wave_amplitude := 120.0
@export var wave_speed := 2.0
@onready var enemy_bullet_sound: AudioStreamPlayer2D = $"../EnemyBulletSound"
@onready var enemy_hit_sound_mech: AudioStreamPlayer2D = $"../MechanicDeath"
@onready var enemy_hit_sound_organic: AudioStreamPlayer2D = $"../OrganicDeath"

var dead := false
var start_y := 0.0
var wave_time := 0.0

func _ready():
	add_to_group("enemies")
	start_y = global_position.y
	shoot_loop()

func _process(delta):
	wave_time += delta
	global_position.x -= speed * delta
	global_position.y = start_y + sin(wave_time * wave_speed) * wave_amplitude

	if global_position.x < -200:
		queue_free()

func shoot_loop():
	while not dead:
		await get_tree().create_timer(fire_interval).timeout
		if not dead:
			shoot()

func take_damage(amount := 1):
	if dead:
		return

	hp -= amount

	if hp <= 0:
		die()

func die():
	dead = true
	remove_from_group("enemies")

	modulate = Color(0.4, 0.4, 0.4, 0.6)
	if Global.organic == 0:
		enemy_hit_sound_mech.play()
	else:
		enemy_hit_sound_organic.play()

	if randf() <= element_n_drop_chance and element_n_scene != null:
		var element_n = element_n_scene.instantiate()
		get_tree().current_scene.add_child(element_n)
		element_n.global_position = global_position

func is_alive():
	return not dead

func shoot():
	if dead:
		return

	var bullet = bullet_scene.instantiate()

	get_tree().current_scene.add_child(bullet)
	enemy_bullet_sound.play()
	bullet.global_position = global_position + Vector2(-60, 0)
