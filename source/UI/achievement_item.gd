class_name AchievementItem extends MarginContainer

@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var name_label: Label = $HBoxContainer/VBoxContainer/NameLabel
@onready var desc_label: Label = $HBoxContainer/VBoxContainer/DescLabel
@onready var finish_label: Label = $HBoxContainer/VBoxContainer/FinishLabel

func init(name_str: String, desc: String, is_finish: bool):
	name_label.text = name_str
	desc_label.text = desc
	finish_label.text = "Finish" if is_finish else "UnFinish"