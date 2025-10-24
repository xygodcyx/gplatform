class_name ReplayingKeyPanel extends Panel

@onready var play_back_action_pack: PackedScene = preload("res://source/UI/playback_action.tscn")

@onready var scroll_container: ScrollContainer = $ScrollContainer

@onready var playback_action_container: HBoxContainer = $ScrollContainer/MarginContainer/PlaybackActionContainer

var last_action: String

var all_play_back_actions: Array[Label] = []

func _ready() -> void:
	ToolManager.remove_all_node_children(playback_action_container)
	SignalManager.playback_action_change.connect(
		func(action_name: String):
			if last_action == action_name: return
			last_action = action_name
			var play_back_action: PlaybackAction = play_back_action_pack.instantiate()
			check_is_expend(action_name.length() * 8 + (all_play_back_actions.size()) * 12 + 8)
			play_back_action.init(action_name)
			all_play_back_actions.push_back(play_back_action)
			playback_action_container.add_child(play_back_action)
	)

func check_is_expend(will_add_width):
	var all_width = calculate_all_playback_action_width()
	# print("all_width: ", all_width)
	if all_width + will_add_width >= scroll_container.size.x * 0.9:
		var action: PlaybackAction = all_play_back_actions.pop_front()
		playback_action_container.remove_child(action)
		action.queue_free()

func calculate_all_playback_action_width() -> int:
	if all_play_back_actions.size() == 0: return 0
	return all_play_back_actions.reduce(
		func(acc, item):
			return item.size.x + acc, 0
	)
