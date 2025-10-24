extends Control

@onready var button_group: Control = $ButtonGroup
@onready var select = $Select
@onready var level_grid_container: MarginContainer = $HBoxContainer/LevelGridContainer
@onready var sub_view_port_display_pack: PackedScene = preload("res://source/UI/sub_view_port_display.tscn")

var cur_index: int = DataManager.select_level_index

func _ready() -> void:
	select_level(cur_index)

func _on_back_menu_pressed() -> void:
	AudioManager.play_sfx_confirm()
	SignalManager.go_menu.emit()

func _on_back_character_pressed() -> void:
	AudioManager.play_sfx_confirm()
	SignalManager.go_choose_character.emit()


func _on_prev_pressed() -> void:
	cur_index = (cur_index + LevelManager.levels.size() - 1) % LevelManager.levels.size()
	select_level(cur_index)

func _on_next_pressed() -> void:
	cur_index = (cur_index + 1) % LevelManager.levels.size()
	select_level(cur_index)

func select_level(index: int):
	ToolManager.remove_all_node_children(level_grid_container)
	var sub_view_port_display: SubViewportDisplay = sub_view_port_display_pack.instantiate() as SubViewportDisplay
	level_grid_container.add_child(sub_view_port_display)
	sub_view_port_display.init(index)
	DataManager.select_level_index = index
