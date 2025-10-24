extends Panel

@onready var achieve_item_pack: PackedScene = preload("res://source/UI/achievement_item.tscn")
@onready var achievement_item_container: GridContainer = %AchievementItemContainer
func _ready() -> void:
	create_achievement_items()

func create_achievement_items():
	ToolManager.remove_all_node_children(achievement_item_container)
	for item in AchievementManager.all_achievement_data:
		var achievement_item: AchievementItem = achieve_item_pack.instantiate()
		achievement_item_container.add_child(achievement_item)
		print(name, " : ", item.name, " : ", item.is_finish)
		achievement_item.init(item.name, item.desc, item.is_finish)
		

func _on_close_button_pressed() -> void:
	SignalManager.go_menu.emit()
