extends Control

func _on_play_button_button_up() -> void:
	get_tree().change_scene("res://src/level/level_" + str($choose_level.value) + ".tscn")


func _on_LinkButton_button_up() -> void:
	OS.shell_open("https://mantevian.itch.io/")
