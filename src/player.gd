extends Sprite

var color := 0

export (int) var x
export (int) var y

var prev_x: int = x
var prev_y: int = y

var direction: int = 0

signal move
signal end_moving

var _pos_mod: Vector2
var _move_timer: int = 0
var _should_emit_end_moving_signal: bool = false
export (int) var max_move_timer = 60

func _process(delta: float) -> void:
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
			
	if Input.is_action_just_pressed("up"):
		direction = 0
		if y > 0:
			emit_signal("move")
		
	if Input.is_action_just_pressed("right"):
		direction = 1
		if x < 31:
			emit_signal("move")
		
	if Input.is_action_just_pressed("down"):
		direction = 2
		if y < 15:
			emit_signal("move")
		
	if Input.is_action_just_pressed("left"):
		direction = 3
		if x > 0:
			emit_signal("move")
	
	if _move_timer > 0:
		_should_emit_end_moving_signal = true
		set_position(position + _pos_mod)
		_move_timer -= 1
	else:
		if _should_emit_end_moving_signal:
			emit_signal("end_moving")
			_should_emit_end_moving_signal = false

func next_color() -> int:
	return (color + 1) % 6
	
func prev_color() -> int:
	return (color + 5) % 6

func update_position() -> void:
	_move_timer = max_move_timer
	_pos_mod = Vector2(x * 32 + 16 - position.x, y * 32 + 16 - position.y) / max_move_timer
