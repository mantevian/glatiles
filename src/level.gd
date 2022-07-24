extends Node2D

func _on_level_tree_exited() -> void:
	get_tree().reload_current_scene()
	
func _on_level_tree_entered() -> void:
	$player.update_position()
	set_colored_cell()

func _on_player_move() -> void:
	if !move_player():
		return

	var stop_following_arrows: bool = false
	
	while get_cell() >= 21 && get_cell() <= 24 && !stop_following_arrows:
		match get_cell():
			21:
				if (is_cell_passable($player.x, $player.y - 1)):
					$player.y -= 1
				else:
					stop_following_arrows = true
			22:
				if (is_cell_passable($player.x + 1, $player.y)):
					$player.x += 1
				else:
					stop_following_arrows = true
			23:
				if (is_cell_passable($player.x, $player.y + 1)):
					$player.y += 1
				else:
					stop_following_arrows = true
			24:
				if (is_cell_passable($player.x - 1, $player.y)):
					$player.x -= 1
				else:
					stop_following_arrows = true
	
	$player.update_position()
	
	if get_cell() == 25:
		$player.color = $player.next_color()
		
	if get_cell() == 33:
		$player.color = $player.prev_color()
	
	if get_cell() >= 26 && get_cell() <= 31:
		$player.color = get_cell() - 26

func get_next_cell() -> int:
	match $player.direction:
		0:
			return $tilemap.get_cell($player.x, $player.y - 1)
		1:
			return $tilemap.get_cell($player.x + 1, $player.y)
		2:
			return $tilemap.get_cell($player.x, $player.y + 1)
		3:
			return $tilemap.get_cell($player.x - 1, $player.y)
	return -1

func move_player() -> bool:
	if !is_passable(get_next_cell()):
		return false
	
	match $player.direction:
		0:
			$player.y -= 1
		1:
			$player.x += 1
		2:
			$player.y += 1
		3:
			$player.x -= 1

	$player.update_position()
	return true

func set_colored_cell() -> void:
	if (get_cell() <= 6 && get_cell() != 0) || get_cell() == 25 || get_cell() == 33:
		$tilemap.set_cell($player.x, $player.y, $player.color + 1)
	elif get_cell() >= 7 && get_cell() <= 13:
		$tilemap.set_cell($player.x, $player.y, get_cell() + 7)

func is_cell_passable(x: int, y: int) -> bool:
	return is_passable($tilemap.get_cell(x, y))

func is_passable(n: int) -> bool:	
	return (n <= 20 && (n - $player.color - 1) % 7 == 0) || n == -1 || n == 7 || n == 14 || n > 20

func check_level_completion() -> bool:
	for x in range(0, 32):
		for y in range(0, 16):
			if $tilemap.get_cell(x, y) >= 7 && $tilemap.get_cell(x, y) <= 13:
				return false
	return true

func get_cell() -> int:
	return $tilemap.get_cell($player.x, $player.y)

func _on_player_end_moving() -> void:
	if $player.x != $player.prev_x || $player.y != $player.prev_y:
		set_colored_cell()
	
	if $next_level:
		$next_level.disabled = !check_level_completion()
	
	$player.prev_x = $player.x
	$player.prev_y = $player.y
