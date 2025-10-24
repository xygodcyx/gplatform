class_name SubViewportDisplay extends Control

@onready var render: SubViewport = $GoLevelButton/SubViewportDisplay/Render
@onready var texture_rect: TextureRect = $LevelIndex/TextureRect

var level_index: int

func init(index: int):
	ToolManager.remove_all_node_children(render)
	level_index = index
	var level_pack_path: String = LevelManager.levels[index]
	var level: Level = load(level_pack_path).instantiate()
	set_node_script_null(level)
	render.add_child(level)
	var path = "res://assets/textures/ui/texture_icon_" + str(level_index + 1).pad_zeros(2) + ".png"
	texture_rect.texture = load(path)

func set_node_script_null(node: Object):
	node.set_script(null)
	for child in node.get_children():
		if child.get_child_count() > 0:
			set_node_script_null(child)

func _on_go_level_button_pressed() -> void:
	SignalManager.go_level.emit(level_index)
	DataManager.save_player_data()
