extends CanvasLayer
class_name DialogueLayer

enum RadioMessage {
	MESSAGE_01,
	MESSAGE_02,
	MESSAGE_03,
	MESSAGE_04,
	COLLECTED,
	GOOD_ENDING,
	BAD_ENDING,
}

@export var message_textures: Array[Texture2D] = [
	preload("res://resources/images/chat/Mensaje01.png"),
	preload("res://resources/images/chat/Mensaje02.png"),
	preload("res://resources/images/chat/Mensaje03.png"),
	preload("res://resources/images/chat/Mensaje04.png"),
	preload("res://resources/images/chat/MensajeRecogido.png"),
	preload("res://resources/images/chat/MensajeFinalBueno.png"),
	preload("res://resources/images/chat/MensajeFinalMalo.png"),
]

@onready var message_image: TextureRect = $MessageImage
@onready var radio_sfx: AudioStreamPlayer2D = $RadioSFX

func _ready():
	message_image.modulate.a = 0.0
	radio_sfx.bus = "SFX"

func show_radio_message(message_index: int):
	if message_index < 0 or message_index >= message_textures.size():
		push_warning("No existe la textura del mensaje %d." % message_index)
		return

	message_image.texture = message_textures[message_index]
	radio_sfx.play()

	message_image.modulate.a = 0.0
	var fade_in := create_tween()
	fade_in.tween_property(message_image, "modulate:a", 1.0, 0.5)
	await fade_in.finished

	await get_tree().create_timer(2.0).timeout

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(message_image, "modulate:a", 0.0, 0.5)

	await tween.finished
