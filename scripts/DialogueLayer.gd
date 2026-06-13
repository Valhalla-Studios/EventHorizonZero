extends CanvasLayer

@onready var message_image: TextureRect = $MessageImage
@onready var message_text: Label = $MessageText
@onready var radio_sfx: AudioStreamPlayer2D = $RadioSFX

func _ready():
	message_image.modulate.a = 0.0
	message_text.modulate.a = 0.0
	radio_sfx.bus = "SFX"

func show_radio_message(text: String):
	radio_sfx.play()

	message_text.text = text
	message_image.modulate.a = 1.0
	message_text.modulate.a = 1.0

	await get_tree().create_timer(4.0).timeout

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(message_image, "modulate:a", 0.0, 1.0)
	tween.tween_property(message_text, "modulate:a", 0.0, 1.0)

	await tween.finished
