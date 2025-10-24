class_name DispatchItem extends Panel

@onready var margin_container: MarginContainer = $MarginContainer
@onready var icon_texture: TextureRect = $MarginContainer/HBoxContainer/IconTexture
@onready var desc_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/DescLabel
@onready var title_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/TitleLabel


func init(title: String, desc: String, icon: Texture, duration: float = 10):
	title_label.text = title
	desc_label.text = desc
	icon_texture.texture = icon
	await get_tree().process_frame
	custom_minimum_size = margin_container.size
	await get_tree().create_timer(duration).timeout
	queue_free()