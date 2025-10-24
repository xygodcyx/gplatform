extends Node

func _ready() -> void:
	init_player_level_data()
	init_player_playback_data()
	load_all_user_data()
	reset_player_playback_trigger_flag()

	SignalManager.go_level.connect(
		func(_level_index):
			init_player_buff()
	)


@onready var player_before_add_buff_prop: Dictionary[String, Variant] = {
	"max_hp": DataManager.max_hp,
	"max_shield_count": DataManager.max_shield_count,
	"max_jump_count": DataManager.max_jump_count,
}

var setting_data: Array[String] = [
	"volume",
	"lang_index"
]

var player_data: Array[String] = [
	"select_player_index",
	"select_level_index",
	"player_level_data",
	"player_playback_data",
]

var achievement_data: Array[String] = [
	"player_achievement_is_finish_data",
	"achieve_deaden_count",
	"achieve_pass_game_count",
	"achieve_replaying_count",
	"achieve_collected_count"
]

var player_achievement_is_finish_data: Dictionary[String, bool]

var achieve_deaden_count: int = 0

var achieve_pass_game_count: int = 0

var achieve_replaying_count: int = 0

var achieve_collected_count: int = 0

var is_in_game: bool = false

var collected_count: int = 0:
	set(value):
		collected_count = value
		SignalManager.collected_count_change.emit(collected_count)

var need_collected_fruit_count: int = 0:
	set(value):
		need_collected_fruit_count = value
		SignalManager.need_collected_fruit_count_change.emit(need_collected_fruit_count)

var all_need_collected_fruit_count: Dictionary[int, int]

var max_jump_count: int = 2

var max_hp: int = 1:
	set(value):
		max_hp = value
		SignalManager.max_hp_change.emit(max_hp)

var hp: int = max_hp:
	set(value):
		hp = value
		if hp <= 0 && !deaden:
			SignalManager.deaden.emit()
			deaden = true
		else:
			SignalManager.hp_change.emit(hp)
			SignalManager.player_injure.emit()

var max_shield_count: int = 0:
	set(value):
		max_shield_count = value
		SignalManager.max_shield_count_change.emit(max_shield_count)

var shield_count: int = max_shield_count:
	set(value):
		shield_count = value
		SignalManager.shield_change.emit(shield_count)
		SignalManager.player_injure.emit()

var volume: float = 100.0:
	set(value):
		volume = value
		SignalManager.volume_change.emit(volume)

var lang_index: int = -1:
	set(value):
		lang_index = value
		SignalManager.lang_index_change.emit(lang_index)
		TranslationServer.set_locale(I18nManager.all_lang[lang_index])

var player_rebirth_point: Vector2

var deaden: bool = false

var deaden_count: int = 0

var game_time: float = 0.0

var game_delta_time: float = 0.0

var game_frame: int = 0

var cur_level_deaden_count: int = 0

var select_player_index: int = 2

var select_level_index: int = 0

var player_level_data: Dictionary[int, Array] = {
	# {
	#	# uuid
	#	"id": ResourceUID.create_id(),
	# 	# timer
	# 	"t": DataManager.game_time,
	# 	# character
	# 	"c": DataManager.select_player_index,
	# 	# deaden_count
	# 	"d": DataManager.cur_level_deaden_count,
	# 	"n": Time.get_unix_time_from_system()
	# }
	0: []
}

enum PlayerActionType {
	MOVEMENT,
	DOWN,
	JUMP
}

var is_replaying: bool = false

var can_record: bool = true

var cur_recording_level_data_id: int

var cur_replaying_level_data_id: int

var last_playback_index = 0

var player_playback_data: Dictionary[int, Array] = {
	0: [
		# {
		# 	"id": cur_recording_level_data_id,
		# 	"playback": [
		#		# 改进：用帧记录回放操作
		#		# {
		#		# 	"frame": Engine.get_physics_frames(),
		#		# 	"action": "ui_left",
		# 		#   "pressed": pressed,
		#		# }
		# 	]
		# }
	]
}

func append_new_playback_data():
	cur_recording_level_data_id = ResourceUID.create_id()
	player_playback_data[LevelManager.will_start_game_index].push_back(
		{
			"id": cur_recording_level_data_id,
			"playback": []
		}
	)

var level_time: float = 0.0
var delta_time: float = 0.0


func _process(delta: float) -> void:
	if is_in_game && !get_tree().paused:
		game_frame += 1

		level_time += delta

		delta_time += delta
	
		game_delta_time = level_time

		if (delta_time >= 1.0):
			delta_time = 0.0
			SignalManager.game_time_update.emit(level_time)

func append_playback(action: String, pressed: bool = true):
	if is_replaying || !can_record: return
	var playback_data = {
			"frame": game_frame,
			"action": action,
			"pressed": pressed,
		}
	var player_level_playback_data = player_playback_data[LevelManager.will_start_game_index]
	var last_index = player_level_playback_data.size() - 1
	player_level_playback_data[last_index]["playback"].push_back(playback_data)

func replaying_playback():
	if !is_replaying: return
	var level_playback_index = find_level_playback_index(cur_replaying_level_data_id)
	if level_playback_index == -1: return
	var level_playback = player_playback_data[LevelManager.will_start_game_index][level_playback_index]
	var cur_index = find_cur_index(level_playback["playback"])
	if cur_index == -1: return
	last_playback_index = cur_index
	var item = level_playback["playback"][cur_index]
	
	if item.action == "": return

	SignalManager.playback_action_change.emit(item.action)

	match item.action:
		"ui_left":
			if item.pressed:
				SignalManager.move_direction.emit(-1)
			else:
				SignalManager.move_direction.emit(0)
		"ui_right":
			if item.pressed:
				SignalManager.move_direction.emit(1)
			else:
				SignalManager.move_direction.emit(0)
		"jump":
			if item.pressed:
				SignalManager.jump_start.emit()
		"ui_down":
			if item.pressed:
				SignalManager.down.emit()
		

func find_level_playback_index(id: int):
	var i = 0
	for item in player_playback_data[LevelManager.will_start_game_index]:
		if item.id == id:
			return i
		i += 1
	return -1

func find_cur_index(data: Array):
	if data.is_empty():
		return -1

	var n := data.size()

	for i in range(0, n):
		var item = data[i]
		if typeof(item) != TYPE_DICTIONARY:
			continue

		var frame := int(item.get("frame", -1))

		if frame < 0:
			continue

		if frame == game_frame:
			return i

	return -1
	
func init_player_buff():
	var buff: CharacterBuff = load(FileManager.all_player_init_buff_path[select_player_index]) as CharacterBuff
	add_player_buff(buff, true)

func add_player_buff(buff: CharacterBuff, is_init: bool = false):
	var prop_list = buff.get_property_list().filter(
		func(v):
			return v.type == 2
	)
	for prop in prop_list:
		var key: String = prop["name"]
		var value = buff.get(key)
		var buff_type: String = key.substr(0, 3)
		var buff_prop_key: String = key.substr(4)

		var effect_prop_key: String = buff_prop_key.substr(4)
		match buff_type:
			"add":
				set(buff_prop_key, (player_before_add_buff_prop[buff_prop_key] if is_init else get(buff_prop_key)) + value)
				set(effect_prop_key, get(buff_prop_key))

func init_player_level_data():
	for i in range(0, LevelManager.levels.size()):
		player_level_data.get_or_add(i, [])

func init_player_playback_data():
	for i in range(0, LevelManager.levels.size()):
		player_playback_data.get_or_add(i, [])

func reset_player_data():
	player_level_data = {}
	player_playback_data = {}
	init_player_level_data()
	init_player_playback_data()
	ToolManager.clear_data("player_data")
	save_player_data()

func reset_achievement_all_data():
	player_achievement_is_finish_data = {}
	AchievementManager.init_achievement_is_finish()
	ToolManager.clear_data("achievement_data")
	for key in achievement_data:
		match typeof(get(key)):
			TYPE_DICTIONARY:
				print("clear: ", get(key))
				set(key, {})
			TYPE_OBJECT:
				set(key, {})
			TYPE_ARRAY:
				set(key, [])
			TYPE_STRING:
				set(key, "")
			TYPE_INT:
				set(key, 0)
			TYPE_FLOAT:
				set(key, 0.0)
		print("clear key: ", key, " -> ", get(key))
	save_achievement_data()

func reset_player_playback_trigger_flag():
	for level_idx in range(0, LevelManager.levels.size()):
		if not player_playback_data.has(level_idx):
			print("not has player_playback_data[{0}}".format([level_idx]))
			continue # 没有该关卡数据就直接跳过
		var level_playback: Array = player_playback_data.get(level_idx)
		if level_playback.size() == 0:
			print("level {0} : level_playback.size = 0".format([level_idx]))
			continue
		# 遍历索引并显式写回，确保修改生效
		for i in range(level_playback.size()):
			var item = level_playback[i]
			if typeof(item) != TYPE_DICTIONARY:
				continue
			var pb = item.get("playback", [])
			for j in range(pb.size()):
				var entry = pb[j]
				if typeof(entry) == TYPE_DICTIONARY:
					entry["is_trigger"] = false
					pb[j] = entry
			item["playback"] = pb
			level_playback[i] = item
		player_playback_data.set(level_idx, level_playback)


func exit_game():
	save_all_user_data_and_exit_game()

func save_all_user_data_and_exit_game():
	await save_all_user_data();
	get_tree().quit()

func save_all_user_data():
	await save_user_setting_data()
	await save_player_data()
	await save_achievement_data()

func load_all_user_data():
	load_user_setting_data()
	load_player_data()
	load_achievement_data()

func save_user_setting_data():
	ToolManager.save_data(self, setting_data, "setting_data")

func load_user_setting_data():
	ToolManager.load_data(self, setting_data, "setting_data")

func save_player_data():
	ToolManager.save_data(self, player_data, "player_data")

func load_player_data():
	ToolManager.load_data(self, player_data, "player_data")

func save_achievement_data():
	ToolManager.save_data(self, achievement_data, "achievement_data")

func load_achievement_data():
	ToolManager.load_data(self, achievement_data, "achievement_data")
