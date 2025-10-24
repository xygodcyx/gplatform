extends Node

var will_start_game_index = 0

var levels: Array[String] = []

func _ready() -> void:
	for path in FileManager.all_level_path:
		# var scene = load(path)
		levels.append(path)