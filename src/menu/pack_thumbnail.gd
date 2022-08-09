extends Control

var pack_name: String = ""

func _on_view_button_button_up() -> void:
	SaveData.set("selected_pack", pack_name)
	get_tree().change_scene("res://src/menu/level_select.tscn")


func _on_properties_button_up() -> void:
	SaveData.set("selected_pack", pack_name)
	get_tree().change_scene("res://src/editor/manage_pack.tscn")


func _on_delete_button_up() -> void:
	get_tree().get_root().get_node("pack_select/confirm").level_order = 0
	get_tree().get_root().get_node("pack_select/confirm").pack_name = pack_name
	get_tree().get_root().get_node("pack_select/confirm").popup()
