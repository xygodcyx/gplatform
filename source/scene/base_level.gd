class_name Level extends Node2D

@export var level_index: int = -1
@export var level_id: int = -1

@onready var end: End = $End
@onready var fruits: Node2D = $Fruits

@onready var spawn: Spawn = $Spawn

var player_pack: PackedScene


func _ready() -> void:
	level_id = level_index

	player_pack = load(FileManager.all_player_path[DataManager.select_player_index])

	DataManager.need_collected_fruit_count = calculate_need_collected_fruit_count(fruits, 0, level_id)

	spawn.reset_spawn_point()
	spawn.set_spawn_point(DataManager.player_rebirth_point)
	spawn.spawn(player_pack)
	
	SignalManager.connect_signal(SignalManager.deaden, _on_deaden)

	SignalManager.connect_signal(SignalManager.player_touch_end, _on_touch_end)

	SignalManager.connect_signal(SignalManager.player_injure, _on_player_injure)


func _on_deaden():
	DataManager.cur_level_deaden_count += 1

func _on_touch_end():
	SignalManager.player_win.emit(level_index, DataManager.is_replaying)
	DataManager.cur_level_deaden_count = 0

func _on_player_injure():
	spawn.set_spawn_point(DataManager.player_rebirth_point)
	spawn.spawn(player_pack)

func calculate_need_collected_fruit_count(parent: Node2D, init_count: int = 0, bind_level_id = -1):
	var hit_cache = DataManager.all_need_collected_fruit_count.has(level_id)
	var count = DataManager.all_need_collected_fruit_count.get(bind_level_id) if hit_cache else init_count
	if hit_cache:
		return count
	count = _calculate_fruit_count(parent, init_count)
	DataManager.all_need_collected_fruit_count.set(level_id, count)
	return count

func _calculate_fruit_count(parent, init_count):
	var count = init_count
	for child in parent.get_children():
		if child.get_child_count() > 0:
			count = _calculate_fruit_count(child, count)
		count += 1 if child.name.contains("Fruit") else 0
	return count