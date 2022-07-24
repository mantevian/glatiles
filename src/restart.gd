extends Button

func _on_restart_button_up() -> void:
	get_tree().reload_current_scene()
