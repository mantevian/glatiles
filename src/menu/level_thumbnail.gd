extends Control

var level_order: int = 1

func _on_play_button_button_up() -> void:
	SaveData.set("selected_level", level_order)
	get_tree().change_scene("res://src/level/level.tscn")
