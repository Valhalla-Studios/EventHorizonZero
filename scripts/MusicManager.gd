extends Node

var menu_music: AudioStreamPlayer

func _ready():
	menu_music = AudioStreamPlayer.new()
	add_child(menu_music)
	menu_music.stream = preload("res://resources/audio/BGM/Menu.mp3")
	menu_music.bus = "Music"
	play_menu_music()

func play_menu_music():
	if not menu_music.playing:
		menu_music.play()

func stop_menu_music():
	menu_music.stop()

func fade_and_quit():

	var fade_tween = create_tween()

	fade_tween.parallel().tween_method(
		_set_music_volume,
		0.0,
		-40.0,
		3.0
	)

	await fade_tween.finished

	
func _set_music_volume(value):
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(music_bus, value)
