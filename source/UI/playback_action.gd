class_name PlaybackAction extends Label

var cur_action_name: String

func _ready() -> void:
	text = cur_action_name

func init(action_name: String):
	cur_action_name = action_name