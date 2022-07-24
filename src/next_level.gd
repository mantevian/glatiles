extends Button

func _on_next_level_button_up() -> void:
	get_tree().change_scene("res://src/level/level_" + str(int(get_tree().current_scene.name) + 1) + ".tscn")
