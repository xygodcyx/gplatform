extends Control

@onready var volume_slider: HSlider = $Panel/NormalSettingContainer/VolumeChange/VolumeSlider
@onready var volume_label: Label = $Panel/NormalSettingContainer/VolumeChange/VolumeLabel
@onready var option_button: OptionButton = $Panel/NormalSettingContainer/LanguageChange/OptionButton

var volume_value: float = 100.0

func _ready() -> void:
	init()

func init():
	init_volume_slider()
	create_lang_option()

func init_volume_slider():
	volume_value = DataManager.volume
	volume_slider.grab_focus.call_deferred()
	volume_slider.value = volume_value
	volume_label.text = str(volume_value)

func create_lang_option():
	for lang in I18nManager.all_lang:
		option_button.add_item(I18nManager.lang_text_map[lang])
	option_button.select(DataManager.lang_index)

# 回到menu
func _on_close_pressed() -> void:
	AudioManager.play_sfx_cancel()
	SignalManager.go_menu.emit()

func _on_save_and_exit_pressed() -> void:
	AudioManager.play_sfx_confirm()
	DataManager.save_user_setting_data()
	SignalManager.go_menu.emit()

func _on_save_pressed() -> void:
	AudioManager.play_sfx_confirm()
	DataManager.save_user_setting_data()

func _on_volume_slider_value_changed(value: float) -> void:
	volume_value = value
	DataManager.volume = volume_value
	volume_label.text = str(volume_value)

func _on_volume_slider_drag_ended(_value_changed: bool) -> void:
	AudioManager.play_sfx_confirm()

func _on_option_button_item_selected(index: int) -> void:
	AudioManager.play_sfx_confirm()
	DataManager.lang_index = index
