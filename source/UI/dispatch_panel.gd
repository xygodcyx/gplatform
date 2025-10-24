extends MarginContainer

@onready var dispatch_item_pack: PackedScene = preload("res://source/UI/dispatch_item.tscn")
@onready var vbox_container: VBoxContainer = $VBoxContainer

func _ready() -> void:
	ToolManager.remove_all_node_children(vbox_container)
	SignalManager.dispatch_info.connect(
		func(title, desc, icon = "event"):
			var dispatch_item: DispatchItem = dispatch_item_pack.instantiate()
			var icon_texture: Texture2D = load("res://assets/textures/ui/icon/" + icon + ".png")
			vbox_container.add_child(dispatch_item)
			dispatch_item.init(title, desc, icon_texture)
	)
