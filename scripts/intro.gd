extends Control

@onready var cutscene_image: TextureRect = $TextureRect
@onready var fade_rect: ColorRect = $FadeRect

var slides: Array[Texture2D] = [
	preload("res://resources/images/cutscenes/intro01.png"),
	preload("res://resources/images/cutscenes/intro02.png"),
	preload("res://resources/images/cutscenes/intro03.png")
]

func _ready():
	fade_rect.visible = true
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	fade_rect.color = Color(0, 0, 0, 1)

	await play_intro()

	if is_inside_tree():
		get_tree().change_scene_to_file("res://scenes/game.tscn")


func play_intro():
	for slide in slides:
		cutscene_image.texture = slide

		await fade_from_black(1.0)
		await get_tree().create_timer(8.0).timeout
		await fade_to_black(1.0)


func fade_from_black(duration: float):
	var tween := create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), duration)
	await tween.finished


func fade_to_black(duration: float):
	var tween := create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), duration)
	await tween.finished
