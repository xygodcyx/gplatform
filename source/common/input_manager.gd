extends Node

var last_move_direction: float

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta) -> void:
	if !DataManager.is_in_game || DataManager.is_replaying: return
	if Input.is_action_just_pressed("ui_down"):
		DataManager.append_playback("ui_down")
		SignalManager.down.emit()
	if Input.is_action_just_pressed("jump"):
		DataManager.append_playback("jump")
		SignalManager.jump_start.emit()
	if Input.is_action_just_pressed("jump"):
		SignalManager.jump_end.emit()

	var move_direction = Input.get_axis("ui_left", "ui_right")

	if move_direction < 0.0:
		DataManager.append_playback("ui_left")
	elif move_direction > 0.0:
		DataManager.append_playback("ui_right")
	else:
		if last_move_direction < 0.0:
			DataManager.append_playback("ui_left", false)
		elif last_move_direction > 0.0:
			DataManager.append_playback("ui_right", false)
	last_move_direction = move_direction

	SignalManager.move_direction.emit(move_direction)
