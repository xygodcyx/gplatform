extends Node2D

const MENU = preload("res://source/UI/menu.tscn")
const CHOOSE_LEVEL = preload("res://source/UI/choose_level.tscn")
const CHOOSE_CHARACTER = preload("res://source/UI/choose_character.tscn")
const SETTING = preload("res://source/UI/setting.tscn")
const RANK = preload("res://source/UI/rank.tscn")
const ACHIEVEMENT = preload("res://source/UI/achievement_panel.tscn")

# 全局ui
@onready var dispatch_panel_pack: PackedScene = preload("res://source/UI/dispatch_panel.tscn")

@onready var ui_layer: CanvasLayer = $UILayer

@onready var state_chart: StateChart = $StateChart

var menu: Menu

var is_init_enter_game: bool = true

var current_scene: Node:
	set(value):
		if current_scene:
			remove_child(current_scene)
			current_scene.queue_free()
			if current_ui_scene:
				current_ui_scene.queue_free()
		current_scene = value
		if value:
			add_child(current_scene)

var current_ui_scene: Control:
	set(value):
		if current_ui_scene:
			ui_layer.remove_child(current_ui_scene)
			current_ui_scene.queue_free()
			if current_scene:
				current_scene.queue_free()
		current_ui_scene = value
		if value:
			ui_layer.add_child(current_ui_scene)

func _ready() -> void:
	init_ui()

	SignalManager.go_menu.connect(
		func():
			state_chart.send_event("to_menu")
	)

	SignalManager.go_rank.connect(
		func():
			state_chart.send_event("to_rank")
	)

	SignalManager.go_achievement.connect(
		func():
			state_chart.send_event("to_achievement")
	)

	SignalManager.go_setting.connect(
		func():
			state_chart.send_event("to_setting")
	)

	SignalManager.go_choose_level.connect(
		func():
			state_chart.send_event("to_choose_level")
	)

	SignalManager.go_choose_character.connect(
		func():
			state_chart.send_event("to_choose_character")
	)

	SignalManager.exit_game.connect(
		func():
			DataManager.exit_game()
	)

	SignalManager.reload_cur_level_scene.connect(
		func(force_index):
			if DataManager.is_in_game:
				DataManager.is_replaying = false
				start_game(force_index if (force_index == 0 || force_index) else LevelManager.will_start_game_index)
	)
	SignalManager.deaden_reload_cur_level_scene.connect(
		func(force_index):
			if DataManager.is_in_game:
				start_game(force_index if (force_index == 0 || force_index) else LevelManager.will_start_game_index)
	)

	SignalManager.go_level.connect(
		func(index):
			DataManager.is_replaying = false
			DataManager.cur_level_deaden_count = 0
			LevelManager.will_start_game_index = index
			state_chart.send_event("to_game")
	)

	SignalManager.go_replaying_level.connect(
		func(record_id, level_index, character_index):
			DataManager.is_replaying = true
			DataManager.cur_replaying_level_data_id = record_id
			DataManager.select_player_index = character_index
			LevelManager.will_start_game_index = level_index
			DataManager.init_player_buff()
			state_chart.send_event("to_game")
	)

func init_ui():
	state_chart.send_event("to_menu")
	ui_layer.add_child(dispatch_panel_pack.instantiate())

func _on_menu_state_entered() -> void:
	DataManager.is_in_game = false
	current_ui_scene = MENU.instantiate()
	AudioManager.play_bgm("menu")

func _on_rank_state_entered() -> void:
	current_ui_scene = RANK.instantiate()
	AudioManager.play_bgm("menu")

func _on_achievement_state_entered() -> void:
	current_ui_scene = ACHIEVEMENT.instantiate()
	AudioManager.play_bgm("menu")

func _on_setting_state_entered() -> void:
	current_ui_scene = SETTING.instantiate()
	AudioManager.play_bgm("menu")

func _on_choose_character_state_entered() -> void:
	current_ui_scene = CHOOSE_CHARACTER.instantiate()
	AudioManager.play_bgm("menu")

func _on_choose_level_state_entered() -> void:
	current_ui_scene = CHOOSE_LEVEL.instantiate()
	AudioManager.play_bgm("menu")

func _on_game_state_entered() -> void:
	print("_on_game_state_entered")
	DataManager.game_frame = 0
	DataManager.game_time = 0
	DataManager.game_delta_time = 0
	DataManager.delta_time = 0
	DataManager.level_time = 0
	current_ui_scene = null
	AudioManager.play_bgm("level")
	if !DataManager.is_replaying:
		DataManager.append_new_playback_data()
	DataManager.can_record = true
	start_game(LevelManager.will_start_game_index)

func _on_game_state_exited() -> void:
	print("_on_game_state_exited")
	DataManager.cur_level_deaden_count = 0
	DataManager.is_in_game = false
	DataManager.can_record = false
	get_tree().paused = false

func start_game(level_index):
	if !is_init_enter_game:
		reset_game_data()
	is_init_enter_game = false
	LevelManager.will_start_game_index = level_index
	current_scene = load(LevelManager.levels[level_index]).instantiate()

func reset_game_data():
	get_tree().paused = false
	DataManager.hp = DataManager.max_hp
	DataManager.shield_count = DataManager.max_shield_count
	DataManager.deaden = false
	DataManager.collected_count = 0
