extends Node2D

const GRAYSCALE_SHADER = preload("res://resources/shaders/death_grayscale.gdshader")

@export var scroll_speed := 100.0
@export var second_planet_speed_multiplier := 1.4
@export var initial_texture: Texture2D

var current_scroll_speed := 100.0

@onready var background_a: Sprite2D = $BackgroundA
@onready var background_b: Sprite2D = $BackgroundB

const BACKGROUND_WIDTH := 1920.0
const HALF_BACKGROUND_WIDTH := BACKGROUND_WIDTH / 2.0

func _ready():
	set_texture(initial_texture)

func _process(delta):
	background_a.position.x -= current_scroll_speed * delta
	background_b.position.x -= current_scroll_speed * delta

	if background_a.position.x <= -HALF_BACKGROUND_WIDTH:
		background_a.position.x = background_b.position.x + BACKGROUND_WIDTH

	if background_b.position.x <= -HALF_BACKGROUND_WIDTH:
		background_b.position.x = background_a.position.x + BACKGROUND_WIDTH

func set_texture(new_texture: Texture2D):
	if new_texture == null:
		return

	background_a.texture = new_texture
	background_b.texture = new_texture
	var is_initial_planet := new_texture == initial_texture
	current_scroll_speed = scroll_speed if is_initial_planet else scroll_speed * second_planet_speed_multiplier
	set_grayscale(is_initial_planet)

func set_grayscale(enabled: bool):
	if not enabled:
		background_a.material = null
		background_b.material = null
		return

	var grayscale_material := ShaderMaterial.new()
	grayscale_material.shader = GRAYSCALE_SHADER
	background_a.material = grayscale_material
	background_b.material = grayscale_material
