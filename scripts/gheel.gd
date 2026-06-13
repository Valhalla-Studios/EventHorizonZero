extends Area2D

@export var speed := 350.0
@export var hp := 1
@export var element_n_scene: PackedScene
@export var element_n_drop_chance := 0.25
@export var bullet_scene: PackedScene
@export var death_texture_mech: Texture2D
@export var death_texture_organic: Texture2D
@onready var enemy_bullet_sound: AudioStreamPlayer2D = $"../EnemyBulletSound"
@onready var enemy_hit_sound_mech: AudioStreamPlayer2D = $"../MechanicDeath"
@onready var enemy_hit_sound_organic: AudioStreamPlayer2D = $"../OrganicDeath"
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


var has_shot := false
var dead := false

func _ready():
	add_to_group("enemies")

	await get_tree().create_timer(randf_range(0.3, 0.8)).timeout

	if not dead:
		shoot()
		has_shot = true

func _process(delta):
	global_position.x -= speed * delta

	if not has_shot and global_position.x < 1400:
		shoot()
		has_shot = true

	if global_position.x < -200:
		queue_free()

func take_damage(amount := 1):
	if dead:
		return

	hp -= amount

	if hp <= 0:
		die()

func die():
	dead = true
	remove_from_group("enemies")

	if Global.organic == 0:
		sprite.texture = death_texture_mech
		enemy_hit_sound_mech.play()
	else:
		sprite.texture = death_texture_organic
		enemy_hit_sound_organic.play()
		Global.report_organic_enemy_destroyed()

	collision_shape.set_deferred("disabled", true)

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
