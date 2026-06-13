extends Node

signal first_organic_enemy_destroyed

var element_n := 0
var required_element_n := 23
var element_n_collected := false
var organic := 0
var organic_enemy_message_shown := false

func report_organic_enemy_destroyed():
	if organic_enemy_message_shown:
		return

	organic_enemy_message_shown = true
	first_organic_enemy_destroyed.emit()
