extends Area2D

var color := 0

export (int) var x
export (int) var y

var direction: int = 0

signal move
signal end_moving

var _pos_mod: Vector2
var max_move_timer = 6
var _move_timer: int = max_move_timer

var _max_press_delay = max_move_timer + 3
var _press_delay: int = _max_press_delay

func _physics_process(delta: float) -> void:
	match color:
		0:
			set_modulate(Color("ff0000"))
		1:
			set_modulate(Color("ff7700"))
		2:
			set_modulate(Color("ffe600"))
		3:
			set_modulate(Color("51ff00"))
		4:
			set_modulate(Color("00ffff"))
		5:
			set_modulate(Color("a600ff"))
	
	if Input.is_action_pressed("up"):
		direction = 0
		if y > 0:
			start_moving()
		
	if Input.is_action_pressed("right"):
		direction = 1
		if x < get_tree().get_root().get_node("level").level_size.x - 1:
			start_moving()
		
	if Input.is_action_pressed("down"):
		direction = 2
		if y < get_tree().get_root().get_node("level").level_size.y - 1:
			start_moving()
		
	if Input.is_action_pressed("left"):
		direction = 3
		if x > 0:
			start_moving()
	
	if _press_delay > 0:
		_press_delay -= 1
	
	if _move_timer > 0:
		set_position(position + _pos_mod)
		_move_timer -= 1
		if _move_timer == 0:
			emit_signal("end_moving")


func start_moving() -> void:
	if _press_delay == 0:
		emit_signal("move")


func next_color() -> int:
	return (color + 1) % 6


func prev_color() -> int:
	return (color + 5) % 6


func update_position() -> void:
	_move_timer = max_move_timer
	_press_delay = _max_press_delay
	_pos_mod = (Vector2(x * 32 + 16, y * 32 + 16) - position) / max_move_timer
