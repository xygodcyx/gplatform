extends HBoxContainer

# pass_panel
@onready var character_portrait: TextureRect = $HBoxContainer/PassLeftInfo/PassInfo/Character/HBoxContainer/CharacterPortrait
@onready var pass_time_label: Label = $HBoxContainer/PassLeftInfo/PassInfo/PassTime/PassTimeLabel
@onready var deaden_count_label: Label = $HBoxContainer/PassLeftInfo/PassInfo/DeadenCount/DeadenCountLabel
@onready var next: Button = $HBoxContainer/PassLeftInfo/PassAction/Next

var is_create_data: bool = false

func _ready() -> void:
	SignalManager.connect_signal(SignalManager.open_pass_panel, _on_open_pass_panel)
	SignalManager.connect_signal(SignalManager.close_pass_panel, _on_close_pass_panel)


func _on_close_pass_panel():
	hide()

func _on_open_pass_panel():
	if is_create_data:
		show()
		return

	is_create_data = true

	show()

	
	var pass_info = {
		# uuid,
		"id": DataManager.cur_recording_level_data_id,
		# timer
		"t": DataManager.game_time,
		# character
		"c": DataManager.select_player_index,
		# deaden_count
		"d": DataManager.cur_level_deaden_count,
		# current_time
		"n": Time.get_unix_time_from_system()
	}
	
	character_portrait.texture = ConstManager.characters[pass_info.get("c")].texture
	pass_time_label.text = str(ToolManager.format_time_str(pass_info.get("t")))
	deaden_count_label.text = str(pass_info.get("d"))
	ToolManager.focus_ui(next)

	if !DataManager.is_replaying:
		var level_data: Array = DataManager.player_level_data.get_or_add(LevelManager.will_start_game_index, [])
		level_data.push_back(pass_info)
		DataManager.save_player_data()
	else:
		DataManager.deaden_count -= DataManager.cur_level_deaden_count

func _on_prev_pressed() -> void:
	AudioManager.play_sfx_confirm()
	SignalManager.go_level.emit(max(0, LevelManager.will_start_game_index - 1))

func _on_next_pressed() -> void:
	AudioManager.play_sfx_confirm()
	SignalManager.go_level.emit(min(LevelManager.levels.size() - 1, LevelManager.will_start_game_index + 1))


func _on_more_button_pressed() -> void:
	SignalManager.open_more_panel.emit()
	SignalManager.close_pass_panel.emit()
	AudioManager.play_sfx_confirm()