extends Control

@onready var fade_rect: ColorRect = $FadeRect

func _ready():
	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 1)

	await get_tree().process_frame

	var tween := create_tween()
	tween.tween_property(
		fade_rect,
		"color",
		Color(0, 0, 0, 0),
		1.5
	)

	await tween.finished

	await get_tree().create_timer(3.0).timeout

	return_to_menu()


func return_to_menu():
	var tween := create_tween()

	tween.tween_property(
		fade_rect,
		"color",
		Color(0, 0, 0, 1),
		1.5
	)

	await tween.finished

	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")