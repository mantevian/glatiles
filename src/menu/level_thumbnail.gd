extends Control

var level_order: int = 1

func _on_play_button_button_up() -> void:
	SaveData.set("selected_level", level_order)
	if SaveData.get("is_loading_level_for_editor"):
		get_tree().change_scene("res://src/editor/level_editor.tscn")
		SaveData._data.editor_data.save = LevelManager.get_level(SaveData.get("selected_pack"), level_order, 1)
		SaveData._data.editor_data.level_order = level_order
		SaveData._data.editor_data.pack_name = SaveData.get("selected_pack")
	else:
		get_tree().change_scene("res://src/level/level.tscn")


func _on_up_button_up() -> void:
	LevelManager.swap_levels(SaveData.get("selected_pack"), level_order, level_order - 1)
	get_tree().reload_current_scene()


func _on_down_button_up() -> void:
	LevelManager.swap_levels(SaveData.get("selected_pack"), level_order, level_order + 1)
	get_tree().reload_current_scene()


func _on_delete_button_up() -> void:
	get_tree().get_root().get_node("level_select/confirm").level_order = level_order
	get_tree().get_root().get_node("level_select/confirm").pack_name = SaveData.get("selected_pack")
	get_tree().get_root().get_node("level_select/confirm").popup()
