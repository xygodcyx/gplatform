class_name PlayerBuffPanel extends VBoxContainer

@onready var player_buff_panel: VBoxContainer = $'.'

var buff_item_pack: PackedScene = preload("res://source/UI/buff_item.tscn")
 
func _ready() -> void:
	init()

func init():
	var buff: CharacterBuff = load(FileManager.all_player_init_buff_path[DataManager.select_player_index])
	var prop_list = buff.get_property_list().filter(
		func(v):
			return v.type == 2
	)
	for prop in prop_list:
		var key: String = prop["name"]
		var buff_type: String = key.substr(0, 3)
		var buff_prop_key: String = key.substr(4)
		var buff_key_array = buff_prop_key.capitalize().split(" ")
		var buff_value: Variant = buff.get(key)

		var buff_item: BuffItem = buff_item_pack.instantiate()

		buff_item.init(buff_key_array, buff_type, str(buff_value))

		player_buff_panel.add_child(buff_item)