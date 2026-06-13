extends Node2D

@onready var battle_music: AudioStreamPlayer2D = $BattleMusic
@onready var fade_rect: ColorRect = $FadeLayer/FadeRect

var ending := false

func game_over():
	if ending:
		return

	ending = true

	$Player.set_process(false)
	$Player.set_physics_process(false)
	$EnemySpawner.set_process(false)

	if $EnemySpawner.has_method("stop_spawning"):
		$EnemySpawner.stop_spawning()

	await get_tree().create_timer(1.5).timeout

	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 0)

	var tween := create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 1.5)
	fade_music()
	await tween.finished

	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")


func fade_music():
	var tween = create_tween()

	tween.tween_method(
		func(value):
			battle_music.volume_db = value,
		battle_music.volume_db,
		-40.0,
		1.5
	)

	await tween.finished

	battle_music.stop()
