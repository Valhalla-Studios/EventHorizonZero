extends Area2D

const WHITE_FLASH_SHADER = preload("res://resources/shaders/white_flash.gdshader")

@export var hp := 100
@export var bullet_scene: PackedScene
@export var fire_interval := 0.45
@export var wave_amplitude := 45.0
@export var wave_speed := 1.2
@onready var bullet_sound: AudioStreamPlayer2D = $BulletSound
@onready var death_sound: AudioStreamPlayer2D = $AncestralDeath
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

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
	bullet_sound.play()

	var shot_offset := randf_range(-125.0, 125.0)
	var bullet = bullet_scene.instantiate()
	var bullet_area := bullet.get_child(0) as Area2D
	if bullet_area != null:
		var vertical_spread := randf_range(-0.18, 0.18)
		bullet_area.set("direction", Vector2(-1.0, vertical_spread))

	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + Vector2(-330, shot_offset)

func take_damage(amount := 1):
	if dead:
		return

	hp -= amount
	if hp <= 0:
		die()

func die():
	dead = true
	remove_from_group("enemies")
	collision_shape.set_deferred("disabled", true)
	bullet_sound.stop()
	death_sound.play()

	var game = get_tree().current_scene
	if game.has_method("lock_player"):
		game.lock_player()

	await flash_before_collapse()

	if game.has_method("fade_boss_music_for_collapse"):
		game.fade_boss_music_for_collapse()

	var collapse := create_tween()
	collapse.set_trans(Tween.TRANS_QUAD)
	collapse.set_ease(Tween.EASE_IN)
	collapse.tween_property(self, "scale", Vector2.ZERO, 1.5)
	await collapse.finished

	if game.has_method("ancestral_defeated"):
		game.ancestral_defeated()

	queue_free()

func flash_before_collapse():
	var flash_material := ShaderMaterial.new()
	flash_material.shader = WHITE_FLASH_SHADER
	sprite.material = flash_material

	for flash in 3:
		flash_material.set_shader_parameter("flash_amount", 1.0)
		await get_tree().create_timer(0.15).timeout
		flash_material.set_shader_parameter("flash_amount", 0.0)
		await get_tree().create_timer(0.15).timeout

	flash_material.set_shader_parameter("flash_amount", 1.0)

func is_alive():
	return not dead
