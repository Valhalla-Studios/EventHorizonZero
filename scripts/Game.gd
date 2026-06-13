extends Node2D

@onready var battle_music: AudioStreamPlayer = $BattleMusic
@onready var fade_rect: ColorRect = $FadeLayer/FadeRect
@onready var dialogue_layer: DialogueLayer = $DialogueLayer
@onready var enemy_spawner = $EnemySpawner
@onready var boss_music: AudioStreamPlayer = $BossMusic
@onready var ancestral_appears: AudioStreamPlayer = $AncestralAppears
@onready var web_way: AudioStreamPlayer2D = $WebWay
@onready var background = $Background

@export var ancestral_scene: PackedScene
@export var boss_background: Texture2D

var ending := false

func _ready():
	Global.organic = 0
	Global.organic_enemy_message_shown = false
	Global.first_organic_enemy_destroyed.connect(_on_first_organic_enemy_destroyed)
	battle_music.play()
	start_dialogue()
	start_organic_phase_timer()
	start_boss_timer()

func start_organic_phase_timer():
	await get_tree().create_timer(60.0).timeout
	if ending:
		return

	Global.organic = 1

func _on_first_organic_enemy_destroyed():
	if ending:
		return

	await dialogue_layer.show_radio_message(DialogueLayer.RadioMessage.MESSAGE_03)

func start_boss_timer():
	await get_tree().create_timer(90.0).timeout
	if ending:
		return

	enemy_spawner.stop_spawning()
	await fade_out_music(battle_music, 1.5)
	ancestral_appears.play()
	await ancestral_appears.finished
	background.set_texture(boss_background)
	clear_battlefield()
	await flash_white()
	boss_music.play()
	spawn_ancestral()

func clear_battlefield():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var enemy_root = enemy.get_parent()
		if enemy_root != null:
			enemy_root.queue_free()
		else:
			enemy.queue_free()

	for bullet in get_tree().get_nodes_in_group("enemy_bullets"):
		var bullet_root = bullet.get_parent()
		if bullet_root != null:
			bullet_root.queue_free()
		else:
			bullet.queue_free()

	for element_n in get_tree().get_nodes_in_group("element_n_pickups"):
		var element_root = element_n.get_parent()
		if element_root != null:
			element_root.queue_free()
		else:
			element_n.queue_free()

func flash_white():
	fade_rect.visible = true

	for flash in 3:
		fade_rect.color = Color(1, 1, 1, 0)
		var fade_in := create_tween()
		fade_in.tween_property(fade_rect, "color:a", 1.0, 0.2)
		await fade_in.finished

		var fade_out := create_tween()
		fade_out.tween_property(fade_rect, "color:a", 0.0, 0.2)
		await fade_out.finished

func spawn_ancestral():
	if ancestral_scene == null:
		return

	var ancestral = ancestral_scene.instantiate()
	ancestral.position = Vector2(1500, 540)
	add_child(ancestral)

func ancestral_defeated():
	if ending:
		return

	ending = true
	stop_gameplay()

	if Global.element_n >= Global.required_element_n:
		await dialogue_layer.show_radio_message(DialogueLayer.RadioMessage.GOOD_ENDING)
		web_way.play()
		await web_way.finished
		await fade_to_scene("res://scenes/ending.tscn", 2.5)
	else:
		await dialogue_layer.show_radio_message(DialogueLayer.RadioMessage.BAD_ENDING)
		await fade_to_scene("res://scenes/GameOver.tscn", 2.5)

func fade_boss_music_for_collapse():
	fade_out_music(boss_music, 1.5)

func lock_player():
	var player_controller = $Player/Player
	player_controller.set_process(false)
	player_controller.set_physics_process(false)

func game_over():
	if ending:
		return

	ending = true
	stop_gameplay()
	await get_tree().create_timer(1.5).timeout
	await fade_to_scene("res://scenes/GameOver.tscn")

func stop_gameplay():
	lock_player()
	$EnemySpawner.set_process(false)

	if $EnemySpawner.has_method("stop_spawning"):
		$EnemySpawner.stop_spawning()

func fade_to_scene(scene_path: String, white_hold_duration := 0.0):
	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 0)

	var tween := create_tween()
	tween.tween_property(fade_rect, "color", Color(255, 255, 255, 1), 1.5)
	if boss_music.playing or battle_music.playing:
		var current_music := boss_music if boss_music.playing else battle_music
		fade_out_music(current_music)
	await tween.finished
	if white_hold_duration > 0.0:
		await get_tree().create_timer(white_hold_duration).timeout

	get_tree().change_scene_to_file(scene_path)


func fade_out_music(music_player: AudioStreamPlayer, duration := 1.5):
	var tween = create_tween()

	tween.tween_method(
		func(value):
			music_player.volume_db = value,
		music_player.volume_db,
		-40.0,
		duration
	)

	await tween.finished

	music_player.stop()

func start_dialogue():
	show_timed_message(10.0, DialogueLayer.RadioMessage.MESSAGE_01)
	show_timed_message(30.0, DialogueLayer.RadioMessage.MESSAGE_02)
	show_timed_message(91.0, DialogueLayer.RadioMessage.MESSAGE_04)

func show_timed_message(delay: float, message: DialogueLayer.RadioMessage):
	await get_tree().create_timer(delay).timeout
	if ending:
		return
	await dialogue_layer.show_radio_message(message)
