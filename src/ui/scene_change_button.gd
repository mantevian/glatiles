extends Button

export (String, FILE) var scene_path := ""

func _on_scene_change_button_button_up() -> void:
	get_tree().change_scene(scene_path)
