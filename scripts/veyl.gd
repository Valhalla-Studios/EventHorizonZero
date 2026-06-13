extends Area2D

const DEATH_SHADER = preload("res://resources/shaders/death_grayscale.gdshader")

@export var initial_speed := 350.0
@export var charge_speed := 800.0
@export var charge_delay := 0.5
@export var close_range := 400.0
@export var close_speed := 1000.0
@export var hp := 3
@export var element_n_scene: PackedScene
@export var element_n_drop_chance := 0.50
@export var death_texture_organic: Texture2D
@onready var enemy_hit_sound_mech: AudioStreamPlayer2D = $"../MechanicDeath"
@onready var enemy_hit_sound_organic: AudioStreamPlayer2D = $"../OrganicDeath"
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var dead := false
var target: Node2D
var is_organic := false
var speed := 350.0

func _ready():
	add_to_group("enemies")
	speed = initial_speed
	is_organic = Global.organic != 0
	target = get_tree().get_first_node_in_group("player") as Node2D
	start_charge()

func start_charge():
	await get_tree().create_timer(charge_delay).timeout
	if not dead:
		speed = charge_speed

func _process(delta):
	if dead:
		return

	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node2D

	if target != null:
		if global_position.distance_to(target.global_position) < close_range:
			speed = close_speed

		var direction := global_position.direction_to(target.global_position)
		global_position += direction * speed * delta
	else:
		global_position.x -= speed * delta

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

	if not is_organic:
		enemy_hit_sound_mech.play()
	else:
		sprite.texture = death_texture_organic
		enemy_hit_sound_organic.play()
		Global.report_organic_enemy_destroyed()

	apply_death_effect()
	collision_shape.set_deferred("disabled", true)

	if randf() <= element_n_drop_chance and element_n_scene != null:
		var element_n = element_n_scene.instantiate()
		get_tree().current_scene.add_child(element_n)
		element_n.global_position = global_position

func apply_death_effect():
	var grayscale_material := ShaderMaterial.new()
	grayscale_material.shader = DEATH_SHADER
	sprite.material = grayscale_material
	sprite.modulate.a = 0.6

func is_alive():
	return not dead
