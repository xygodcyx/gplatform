extends Node


var all_level_path: Array[String] = []
var all_player_path: Array[String] = []
var all_player_init_buff_path: Array[String] = []
var all_player_achievement_path: Array[String] = []

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    all_level_path = get_all_scenes_in_directory("res://source/scene/levels")
    all_player_path = get_all_scenes_in_directory("res://source/entity/character", ["player.tscn"])
    
    all_player_init_buff_path = get_all_tres_in_directory("res://source/resources/character/init_buff")

    all_player_achievement_path = get_all_tres_in_directory("res://source/resources/achievement/achieve")


func get_all_scenes_in_directory(path: String, exclude: Array[String] = []):
    return get_all_res_in_directory(path, ".tscn", exclude)


func get_all_tres_in_directory(path: String, exclude: Array[String] = []):
    return get_all_res_in_directory(path, ".tres", exclude)

func get_all_res_in_directory(path: String, suffix: String, exclude: Array[String] = []):
    var scenes: Array[String] = []
    var files = ResourceLoader.list_directory(path)
    for file in files:
        var file_name: String = file
        if file_name.ends_with("/") or file_name == "":
            continue
        if exclude.has(file_name) or not file_name.ends_with(suffix):
            continue
        var file_path = path + "/" + file_name
        scenes.append(file_path)
    return scenes