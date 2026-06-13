extends Control

@onready var start_button = $StartButton
@onready var options_button = $OptionsButton
@onready var exit_button = $ExitButton
@onready var fade_rect = $FadeRect
@onready var button_sfx = $ButtonSFX
var changing_scene := false


func _ready():
	MusicManager.play_menu_music()
	button_sfx.bus = "SFX"

	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _play_click_sfx():
	button_sfx.play()

func _on_start_pressed():
	if changing_scene:
		return

	changing_scene = true
	_play_click_sfx()
	await get_tree().create_timer(0.15).timeout
	await fade_to_black(1.5)
	MusicManager.stop_menu_music()
	get_tree().change_scene_to_file("res://scenes/intro.tscn")

func _on_options_pressed():
	_play_click_sfx()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/options.tscn")

func _on_exit_pressed():
	_play_click_sfx()
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	await fade_to_black(1.5)
	MusicManager.fade_and_quit()
	get_tree().quit()


func fade_to_black(duration: float):
	fade_rect.visible = true
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	fade_rect.color = Color(0, 0, 0, 0)

	var tween := create_tween()

	tween.tween_property(
		fade_rect,
		"color",
		Color(0, 0, 0, 1),
		duration
	)

	await tween.finished
