extends Node

var cur_select: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if cur_select and event.is_action_pressed("ui_accept"):
		cur_select.grab_focus()
