extends HBoxContainer

@onready var player_level_data_content_container: VBoxContainer = $PanelLeftInfo/MarginContainer/HBoxContainer/VBoxContainer/ScrollContainer/PlayerLevelDataContainer/PlayerLevelDataContentContainer

@onready var level_index_container: VBoxContainer = $PanelLeftInfo/MarginContainer/HBoxContainer/LevelIndexContainer

@onready var back_button: Button = $PanelRightAction/BackButton

var is_create_data: bool = false
func _ready() -> void:
	SignalManager.connect_signal(SignalManager.open_more_panel, _on_open_more_panel)
	SignalManager.connect_signal(SignalManager.close_more_panel, _on_close_more_panel)

func _on_close_more_panel():
	hide()

func _on_open_more_panel():
	if is_create_data:
		show()
		return
	is_create_data = true
	show()
	create_level_index_str_with_local()
	create_rank_table_rows()
	ToolManager.focus_ui(back_button)
	

func create_rank_table_rows():
	ToolManager.remove_all_node_children(player_level_data_content_container)
	
	ToolManager.create_rank_table_rows(player_level_data_content_container, LevelManager.will_start_game_index)


func create_level_index_str_with_local():
	var local = TranslationServer.get_locale()

	for child in level_index_container.get_children():
		level_index_container.remove_child(child)
	
	var label1 = Label.new()
	var label2 = Label.new()
	var label3 = Label.new()

	label1.self_modulate = "fa8080"
	label2.self_modulate = "fa8080"
	label3.self_modulate = "fa8080"

	label1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var level_index = LevelManager.will_start_game_index + 1
	match local:
		"zh_CN":
			label1.text = "第"
			label2.text = str(ConstManager.chinese_number[level_index])
			label3.text = "关"
		"zh_TW":
			label1.text = "第"
			label2.text = str(ConstManager.chinese_number[level_index])
			label3.text = "關"
		"en":
			label1.text = "Level"
			label2.text = str(level_index)
	
	level_index_container.add_child(label1)
	level_index_container.add_child(label2)
	level_index_container.add_child(label3)

func _on_back_button_pressed() -> void:
	SignalManager.close_more_panel.emit()
	SignalManager.open_pass_panel.emit()
	AudioManager.play_sfx_confirm()
