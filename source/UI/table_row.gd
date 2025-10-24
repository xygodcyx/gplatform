class_name TableRow extends Control

@onready var tag_label_control: Control = $TagLabelControl
@onready var tag_label: Label = $TagLabelControl/TagLabel
@onready var character_portrait: TextureRect = $TableRowBox/HBoxContainer/CharacterPortrait
@onready var pass_time_table_label: Label = $TableRowBox/PassTimeTableLabel
@onready var deaden_count_table_label: Label = $TableRowBox/DeadenCountTableLabel

var cur_record_id: int

var cur_level_index: int

var cur_character_index: int

func init(character_index: int, pass_time_str: String, deaden_count: int, record_id: int, level_index: int, tag_text: String = "", preset: LayoutPreset = LayoutPreset.PRESET_CENTER):
	var texture: Texture2D = ConstManager.characters[character_index].texture
	character_portrait.texture = texture
	pass_time_table_label.text = pass_time_str
	deaden_count_table_label.text = str(deaden_count)

	cur_record_id = record_id
	cur_level_index = level_index
	cur_character_index = character_index

	if tag_text != "":
		tag_label.text = tag_text
		tag_label_control.show()
		tag_label.set_anchors_preset(preset, true)
		match preset:
			LayoutPreset.PRESET_CENTER_LEFT:
				tag_label.position.x = 0.0
				pass
			LayoutPreset.PRESET_CENTER:
				pass
				# tag_label.position.x = 77.0
				tag_label.position.y -= 6

func _on_playback_button_pressed() -> void:
	DataManager.cur_replaying_level_data_id = cur_record_id
	print(cur_record_id, " ", cur_level_index)
	# var index = DataManager.player_playback_data[cur_level_index].find_custom(
	# 	func(item):
	# 		return item.id == cur_record_id
	# )
	for item in DataManager.player_playback_data.get(cur_level_index):
		print("id: ", item.id)
	printraw(DataManager.player_playback_data[cur_level_index])
	SignalManager.go_replaying_level.emit(cur_record_id, cur_level_index, cur_character_index)