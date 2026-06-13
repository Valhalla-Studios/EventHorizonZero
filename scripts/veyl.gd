extends Area2D

@export var speed := 150.0
@export var hp := 3
@export var element_n_scene: PackedScene
@export var element_n_drop_chance := 0.50
@onready var enemy_hit_sound_mech: AudioStreamPlayer2D = $"../MechanicDeath"
@onready var enemy_hit_sound_organic: AudioStreamPlayer2D = $"../OrganicDeath"

var dead := false
var target: Node2D

func _ready():
	add_to_group("enemies")
	target = get_tree().get_first_node_in_group("player") as Node2D

func _process(delta):
	if dead:
		return

	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node2D

	if target != null:
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
