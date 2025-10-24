extends Control

@onready var level_switch: TabBar = %LevelSwitch
@onready var level_data_panel_container: VBoxContainer = %LevelDataPanelContainer

func _ready() -> void:
	create_tabs()
	create_rank_table(0)

func _on_level_switch_tab_changed(tab: int) -> void:
	create_rank_table(tab)

func create_tabs():
	for index in LevelManager.levels.size():
		level_switch.add_tab(ToolManager.get_str_with_local("LEVEL") + ToolManager.get_str_with_local(str(index + 1)))

func create_rank_table(index: int):
	ToolManager.remove_all_node_children(level_data_panel_container)
	ToolManager.create_rank_table_rows(level_data_panel_container, index)


func _on_close_pressed() -> void:
	SignalManager.go_menu.emit()
