extends Area2D

var half_width := 110
var half_height := 50
var dead := false

@export var speed := 650.0
@export var bullet_scene: PackedScene
@export var fire_rate := 0.15
@export var invulnerable := false

@onready var player_bullet_sound: AudioStreamPlayer2D = $LancerBulletSound
@onready var player_dead_sound: AudioStreamPlayer2D = $MechanicDeath
@onready var element_n_label: Label = $ElementNLabel
@onready var time_label: Label = $TimeLabel

var can_shoot := true
var elapsed_time := 0.0
var displayed_second := 0
var displayed_element_n := -1

func _ready():
	add_to_group("player")
	area_entered.connect(_on_area_entered)
	update_element_n_label()
	update_time_label()

func _process(delta):
	if dead:
		return

	elapsed_time += delta
	var current_second := int(elapsed_time)
	if current_second != displayed_second:
		displayed_second = current_second
		update_time_label()

	if Global.element_n != displayed_element_n:
		update_element_n_label()

	var direction := Vector2.ZERO

	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	direction = direction.normalized()

	position += direction * speed * delta

	position.x = clamp(position.x, half_width, 1920 - half_width)
	position.y = clamp(position.y, half_height, 1080 - half_height)

	if Input.is_action_pressed("ui_accept") and can_shoot:
		shoot()

func update_time_label():
	var minutes := int(displayed_second / 60.0)
	var seconds := displayed_second % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]

func update_element_n_label():
	displayed_element_n = Global.element_n
	element_n_label.text = "Element N: %d / %d" % [
		Global.element_n,
		Global.required_element_n
	]

func shoot():
	can_shoot = false

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	bullet.global_position = global_position + Vector2(120, 0)
	player_bullet_sound.play()
	await get_tree().create_timer(fire_rate).timeout

	can_shoot = true

func _on_area_entered(area):

	if area.is_in_group("enemy_bullets"):
		die()

	if area.is_in_group("enemies"):
		if area.has_method("is_alive") and area.is_alive():
			die()

func die():
	if dead or invulnerable:
		return

	player_dead_sound.play()
	dead = true

	get_tree().current_scene.game_over()
