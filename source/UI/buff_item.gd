class_name BuffItem extends HBoxContainer

var buff_key_array: Array
var buff_type: String
var buff_value: Variant

func _ready() -> void:
	for key_str in buff_key_array:
		var label: Label = Label.new()
		label.text = key_str
		add_child(label)

	var value_label: Label = Label.new()
	value_label.self_modulate = "#eb6b6b"
	match buff_type:
		"add":
			value_label.text = "+"
	value_label.text += buff_value
	add_child(value_label)

func init(key_array: Array, type: String, value: Variant):
	buff_key_array = key_array
	buff_type = type
	buff_value = value
