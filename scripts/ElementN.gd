extends Area2D

@export var speed := 250.0
@export var amount := 1
@onready var player_collect: AudioStreamPlayer2D = $CollectSound

func _ready():
	area_entered.connect(_on_area_entered)

func _process(delta):
	global_position.x -= speed * delta

	if global_position.x < -100:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("player"):
		Global.element_n += amount
		player_collect.play()

		if Global.element_n >= 1 and not Global.element_n_collected:
			Global.element_n_collected = true
			var dialogue_layer = get_tree().current_scene.get_node_or_null("DialogueLayer")
			if dialogue_layer != null:
				dialogue_layer.show_radio_message(
					DialogueLayer.RadioMessage.COLLECTED
				)

		queue_free()
