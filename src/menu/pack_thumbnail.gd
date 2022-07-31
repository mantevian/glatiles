extends Control

var pack_name: String = ""

func _on_view_button_button_up() -> void:
	SaveData.set("selected_pack", pack_name)
	get_tree().change_scene("res://src/menu/level_select.tscn")
