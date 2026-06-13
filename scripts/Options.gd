extends Control

@onready var music_slider: HSlider = $MusicSlider
@onready var sfx_slider: HSlider = $SFXSlider
@onready var back_button = $BackButton
@onready var button_sfx = $ButtonSFX


var music_bus: int
var sfx_bus: int

func _ready():
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")

	music_slider.min_value = -40
	music_slider.max_value = 0
	music_slider.step = 1
	sfx_slider.min_value = -40
	sfx_slider.max_value = 0
	sfx_slider.step = 1

	music_slider.value = AudioServer.get_bus_volume_db(music_bus)
	sfx_slider.value = AudioServer.get_bus_volume_db(sfx_bus)

	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	back_button.pressed.connect(_on_back_pressed)

func _play_click_sfx():
	button_sfx.play()

func _on_music_slider_changed(value: float):
	print("Music volume:", value)
	AudioServer.set_bus_volume_db(music_bus, value)

func _on_sfx_slider_changed(value: float):
	AudioServer.set_bus_volume_db(sfx_bus, value)


func _on_back_pressed():
	_play_click_sfx()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
	
