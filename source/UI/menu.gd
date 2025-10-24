class_name Menu extends Control

@onready var button_group: VBoxContainer = $CenterButtonAction/ButtonGroup
@onready var version_label: Label = $RightBottomVersion/VersionLabel

func _ready() -> void:
	(button_group.get_child(0) as Button).grab_focus.call_deferred()
	version_label.text = ":" + ProjectSettings.get("application/config/version")

func _on_start_pressed() -> void:
	AudioManager.play_sfx_confirm()
	SignalManager.go_choose_character.emit()

func _on_setting_pressed() -> void:
	AudioManager.play_sfx_confirm()
	SignalManager.go_setting.emit()

func _on_exit_game_pressed() -> void:
	AudioManager.play_sfx_confirm()
	SignalManager.exit_game.emit()

func _on_rank_button_pressed() -> void:
	SignalManager.go_rank.emit()

func _on_archive_button_pressed() -> void:
	SignalManager.go_achievement.emit()

func _on_clear_data_button_pressed() -> void:
	DataManager.reset_player_data()
	DataManager.reset_achievement_all_data()
	DataManager.load_all_user_data()
