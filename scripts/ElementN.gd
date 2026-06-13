extends Area2D

@export var speed := 250.0
@export var amount := 1
@onready var player_collect: AudioStreamPlayer2D = $CollectSound
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var collected := false

func _ready():
	add_to_group("element_n_pickups")
	area_entered.connect(_on_area_entered)

func _process(delta):
	if collected:
		return

	global_position.x -= speed * delta

	if global_position.x < -100:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("player") and not collected:
		collected = true
		Global.element_n += amount
		sprite.visible = false
		collision_shape.set_deferred("disabled", true)
		player_collect.play()

		if Global.element_n >= 1 and not Global.element_n_collected:
			Global.element_n_collected = true
			var dialogue_layer = get_tree().current_scene.get_node_or_null("DialogueLayer")
			if dialogue_layer != null:
				dialogue_layer.show_radio_message(
					DialogueLayer.RadioMessage.COLLECTED
				)

		await player_collect.finished
		get_parent().queue_free()
