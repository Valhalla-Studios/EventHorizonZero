extends Area2D

var half_width := 110
var half_height := 50
var dead := false

@export var speed := 650.0

@export var bullet_scene: PackedScene
@export var fire_rate := 0.15

var can_shoot := true

func _ready():
	add_to_group("player")
	area_entered.connect(_on_area_entered)

func _process(delta):
	if dead:
		return

	var direction := Vector2.ZERO

	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	direction = direction.normalized()

	position += direction * speed * delta

	position.x = clamp(position.x, half_width, 1920 - half_width)
	position.y = clamp(position.y, half_height, 1080 - half_height)

	if Input.is_action_pressed("ui_accept") and can_shoot:
		shoot()

func shoot():
	can_shoot = false

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	bullet.global_position = global_position + Vector2(120, 0)

	await get_tree().create_timer(fire_rate).timeout

	can_shoot = true

func _on_area_entered(area):

	if area.is_in_group("enemy_bullets"):
		die()

	if area.is_in_group("enemies"):
		if area.has_method("is_alive") and area.is_alive():
			die()

func die():
	if dead:
		return

	dead = true

	get_tree().current_scene.game_over()
