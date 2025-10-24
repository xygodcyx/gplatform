extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func format_time_str(time: float) -> String:
	var hour = int(time / (60 * 60))
	var minute = int(time / 60) % 60
	var second = int(time) % 60
	var game_time_str = ((str(hour).pad_zeros(2) + ":") if hour > 0 else "") + str(minute).pad_zeros(2) + ":" + str(second).pad_zeros(2)
	return game_time_str


func is_mobile_device() -> bool:
	# 1️⃣ 先判断是否为 Web 环境
	if OS.has_feature("web"):
		var agent: Variant = JavaScriptBridge.eval("navigator.userAgent")
		if agent != null:
			agent = agent.to_lower()
			if agent.find("android") != -1 or agent.find("iphone") != -1 or agent.find("ipad") != -1:
				return true
			if agent.find("mobile") != -1:
				return true
		var js_width = JavaScriptBridge.eval("window.innerWidth")
		if js_width < 900:
			return true
		return false

	if OS.has_feature("android") or OS.has_feature("ios"):
		return true

	var screen_size = DisplayServer.screen_get_size()

	if screen_size.x < 900 and screen_size.y < 900:
		return true

	return false


func focus_ui(ui: Control) -> void:
	ui.grab_focus.call_deferred()

func remove_all_node_children(node: Node):
	if node == null:
		printerr("cannt remove_child from null")
		print_stack()
		return
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func create_rank_table_rows(parent: Control, want_level_index: int):
	var table_row_pack: PackedScene = load("res://source/UI/table_row.tscn")
	var level_data = DataManager.player_level_data[want_level_index]
	if level_data == null || level_data.size() == 0:
		return
	
	var best_data = level_data.reduce(
		func(best, item):
			return item if item.t < best.t else best
	)
	
	init_rank_table_row(parent, best_data, table_row_pack, want_level_index, "BEST", Control.PRESET_CENTER)
	
	level_data.sort_custom(
		func(a, b):
			return a.n > b.n
	)
	var i: int = 0
	for item in level_data:
		if i == 0:
			init_rank_table_row(parent, item, table_row_pack, want_level_index, "NEWEST", Control.PRESET_CENTER)
		else:
			init_rank_table_row(parent, item, table_row_pack, want_level_index)
		i += 1

func init_rank_table_row(parent: Control, item: Variant, table_row_pack: PackedScene, want_level_index: int, tag_text: String = "", preset: Variant = Control.PRESET_CENTER):
		var table_row: TableRow = table_row_pack.instantiate()
		var pass_time_str: String = ToolManager.format_time_str(item.t)
		var deaden_count: int = item.d
		var record_id: int = item.id
		parent.add_child(table_row)
		table_row.init(item.c, pass_time_str, deaden_count, record_id, want_level_index, tag_text, preset)
		return table_row


func get_str_with_local(origin: StringName):
	var local = TranslationServer.get_locale()
	var t: Translation = TranslationServer.get_translation_object(local)
	return t.tr(origin)

func get_res_custom_prop(res: Resource, flag: PropertyUsageFlags = PropertyUsageFlags.PROPERTY_USAGE_EDITOR):
	var custom_props: Array[String] = []
	var empty_res_instance: Resource = Resource.new()
	var empty_res_prop = empty_res_instance.get_property_list().map(
		func(v):
			return v.name
	)
	for prop in res.get_property_list():
		print(prop)
		if prop.name in empty_res_prop:
			continue
		if prop.usage != 4102 && prop.usage != 4096:
			continue
		custom_props.push_back(prop.name)
	return custom_props

func save_data(source: Object, save_keys: Array[String], section: String):
	var config = ConfigFile.new()
	for key in save_keys:
		config.set_value(section, key, source.get(key))
	config.save("user://{0}.cfg".format([section]))
	SignalManager.save_data_complete.emit()
	await get_tree().process_frame

func load_data(source: Object, load_keys: Array[String], section: String):
	var config = ConfigFile.new()

	var err = config.load("user://{0}.cfg".format([section]))

	if err != OK:
		return

	for key in load_keys:
		var value = config.get_value(section, key, source.get(key))
		source.set(key, value)

func clear_data(section: String):
	var config = ConfigFile.new()
	var err = config.load("user://{0}.cfg".format([section]))
	if err != OK:
		return
	config.erase_section(section)
