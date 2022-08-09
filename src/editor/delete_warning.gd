extends ConfirmationDialog


var pack_name = ""
var level_order = 0


func _on_confirm_confirmed() -> void:
	if level_order == 0:
		LevelManager.delete_pack(pack_name)
	else:
		LevelManager.delete_level(pack_name, level_order)
	
	get_tree().reload_current_scene()


func _on_confirm_ready() -> void:
	pass


func _on_confirm_about_to_show() -> void:
	var pack_display_name = LevelManager.get_pack(pack_name).display_name
	if level_order == 0:
		$container/name.text = "pack " + pack_display_name
	else:
		$container/name.text = "level " + LevelManager.get_level(pack_name, level_order, 1).level_name + " of " + pack_display_name
