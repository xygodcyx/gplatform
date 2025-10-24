extends Control

@onready var confirm: Button = $ChooseCharacterPanel/Confirm
@onready var character_name: Label = $ChooseCharacterPanel/CharacterName
@onready var character_portrait: TextureRect = $ChooseCharacterPanel/CharacterPlaceholder/CharacterPortrait
@onready var player_buff_panel_control: Control = $ChooseCharacterPanel/PlayerBuffPanelControl
@onready var player_init_buff_panel_pack: PackedScene = preload("res://source/UI/player_buff_panel.tscn")

var select_index = DataManager.select_player_index
func _ready() -> void:
	confirm.grab_focus.call_deferred()
	select(select_index)

func _on_back_menu_pressed() -> void:
	AudioManager.play_sfx_confirm()
	SignalManager.go_menu.emit()

func _on_next_pressed() -> void:
	AudioManager.play_sfx_confirm()
	var next_index = (select_index + 1) % ConstManager.characters.size()
	select(next_index)

func _on_prev_pressed() -> void:
	AudioManager.play_sfx_confirm()
	var prev_index = ((select_index - 1) + ConstManager.characters.size()) % ConstManager.characters.size()
	select(prev_index)

func _on_confirm_pressed() -> void:
	AudioManager.play_sfx_confirm()
	DataManager.select_player_index = select_index
	DataManager.save_player_data()
	SignalManager.go_choose_level.emit()

func select(index):
	select_index = index
	character_portrait.texture = ConstManager.characters[select_index].texture
	character_name.text = ConstManager.characters[select_index].name
	DataManager.select_player_index = select_index
	show_player_buff_display()
	SignalManager.select_player_index_change.emit(select_index)

func show_player_buff_display():
	ToolManager.remove_all_node_children(player_buff_panel_control)
	var panel: PlayerBuffPanel = player_init_buff_panel_pack.instantiate()
	player_buff_panel_control.add_child(panel)
