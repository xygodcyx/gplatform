extends Control

# 运行时信息
@onready var collected_count_label: Label = $PlayerInfo/VBoxContainer/CollectedCount/CollectedCountLabel
@onready var need_collected_fruit_count_label: Label = $PlayerInfo/VBoxContainer/CollectedCount/NeedCollectedFruitCountLabel

@onready var hp_label: Label = $PlayerInfo/VBoxContainer/Hp/HpLabel
@onready var max_hp_label: Label = $PlayerInfo/VBoxContainer/Hp/MaxHpLabel

@onready var shield_label: Label = $PlayerInfo/VBoxContainer/Shield/ShieldLabel
@onready var max_shield_label: Label = $PlayerInfo/VBoxContainer/Shield/MaxShieldLabel

@onready var deaden_label: Label = $PlayerInfo/VBoxContainer/Deaden/DeadenLabel
@onready var time_label: Label = $TopInfo/TimeLabel
@onready var replaying_label: Label = $TopInfo/ReplayingLabel

@onready var replaying_key_panel: ReplayingKeyPanel = $BottomInfo/ReplayingKeyPanel
@onready var global_effect: ColorRect = $GlobalEffect

# 移动端按钮
@onready var game_pad: Control = $GamePad

func _ready() -> void:
	if ToolManager.is_mobile_device():
		game_pad.show()
	else:
		game_pad.hide()

	refresh_replaying_info_show()
	
	SignalManager.need_collected_fruit_count_change.connect(
		func(need_collected_fruit_count):
			need_collected_fruit_count_label.text = " / " + str(need_collected_fruit_count)
	)

	SignalManager.collected_count_change.connect(
		func(collected_count):
			collected_count_label.text = "x " + str(collected_count)
	)
	
	SignalManager.max_hp_change.connect(
		func(max_hp):
			max_hp_label.text = " / " + str(max_hp)
	)
	
	SignalManager.hp_change.connect(
		func(hp):
			hp_label.text = "x " + str(hp)
	)

	SignalManager.max_shield_count_change.connect(
		func(max_shield):
			max_shield_label.text = " / " + str(max_shield)
	)
	
	SignalManager.shield_change.connect(
		func(shield):
			shield_label.text = "x " + str(shield)
	)

	SignalManager.deaden.connect(
		func():
			DataManager.deaden_count += 1
			deaden_label.text = "x " + str(DataManager.deaden_count)
	)

	SignalManager.game_time_update.connect(
		func(time: float):
			var format_time = ToolManager.format_time_str(time)
			time_label.text = format_time
			DataManager.game_time = time
	)

	SignalManager.connect_signal(SignalManager.player_win, _on_player_win)

	init()

func _on_player_win(_level_id, _is_replaying):
	get_tree().paused = true
	SignalManager.open_pass_panel.emit()
	DataManager.can_record = false
	refresh_replaying_info_show(false)
	DataManager.save_player_data()

func init():
	collected_count_label.text = "x " + str(DataManager.collected_count)
	
	hp_label.text = "x " + str(DataManager.hp)

	max_hp_label.text = " / " + str(DataManager.max_hp)

	shield_label.text = "x " + str(DataManager.shield_count)

	max_shield_label.text = " / " + str(DataManager.max_shield_count)

	deaden_label.text = "x " + str(DataManager.deaden_count)

	time_label.text = ToolManager.format_time_str(DataManager.game_time)

func refresh_replaying_info_show(if_show: bool = true):
	replaying_label.text = tr("Replaying") + "..."
	if if_show && DataManager.is_replaying:
		replaying_label.show()
		replaying_key_panel.show()
		global_effect.show()
	else:
		replaying_label.hide()
		replaying_key_panel.hide()
		global_effect.hide()

func _on_restart_pressed() -> void:
	AudioManager.play_sfx_confirm()
	SignalManager.go_level.emit(LevelManager.will_start_game_index)

func _on_back_choose_level_pressed() -> void:
	AudioManager.play_sfx_confirm()
	SignalManager.go_choose_level.emit()
