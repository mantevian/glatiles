extends Control

func _on_play_button_button_up() -> void:
	SaveData.selected_level = "level_" + str($choose_level.value)
	SaveData.save_data()
	get_tree().change_scene("res://src/level/level.tscn")


func _on_LinkButton_button_up() -> void:
	OS.shell_open("https://mantevian.itch.io/")


func _on_menu_tree_entered() -> void:
	SaveData.load_data()
	if SaveData.is_main_level_selected:
		$choose_level.value = int(SaveData.selected_level)


func _on_quit_button_button_up() -> void:
	get_tree().quit()
