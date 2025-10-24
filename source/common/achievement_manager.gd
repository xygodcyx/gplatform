extends Node


var all_achievement_data: Array[Achievement]

func _ready():
	init_data()
	init_achievement_is_finish()

	SignalManager.deaden.connect(
		func():
			DataManager.achieve_deaden_count += 1
			SignalManager.achieve_prop_value_change.emit()
	)

	SignalManager.player_win.connect(
		func(_level_index, _is_replaying):
			DataManager.achieve_pass_game_count += 1
			SignalManager.achieve_prop_value_change.emit()
	)

	SignalManager.go_replaying_level.connect(
		func(_cur_record_id, _cur_level_index, _cur_character_index):
			DataManager.achieve_replaying_count += 1
			SignalManager.achieve_prop_value_change.emit()
	)

	SignalManager.collected_count_change.connect(
		func(count):
			if count > 0:
				DataManager.achieve_collected_count += 1
			SignalManager.achieve_prop_value_change.emit()
	)

	SignalManager.achieve_prop_value_change.connect(
		func():
			var finish_item = refresh_all_achievement_is_finish()
			if !finish_item: 
				print(DataManager.achieve_collected_count)
				return
			SignalManager.dispatch_info.emit(finish_item.name, "Finish")
			DataManager.save_achievement_data()
	)

func init_data():
	all_achievement_data = []
	for item in FileManager.all_player_achievement_path:
		var data: Achievement = load(item)
		all_achievement_data.push_back(data)

func init_achievement_is_finish():
	for item in all_achievement_data:
		item.is_finish = DataManager.player_achievement_is_finish_data.get_or_add(item.name, false)

func refresh_all_achievement_is_finish() -> Achievement:
	# 返回新完成的成就
	for achieve_item: Achievement in all_achievement_data:
		var condition: Array[AchievementCondition] = achieve_item.condition

		var is_finish = false
		
		for condition_item: AchievementCondition in condition:
			var check_prop = condition_item.check_prop
			var operator = condition_item.operator
			var operand = condition_item.operand
			# print(check_prop, operator, operand)
			var actual_prop_value = DataManager.get(check_prop)

			match operator:
				">=":
					if actual_prop_value >= operand:
						is_finish = true
					else:
						is_finish = false
				">":
					if actual_prop_value > operand:
						is_finish = true
					else:
						is_finish = false
				"<=":
					if actual_prop_value <= operand:
						is_finish = true
					else:
						is_finish = false
				"<":
					if actual_prop_value < operand:
						is_finish = true
					else:
						is_finish = false
				"==":
					if actual_prop_value == operand:
						is_finish = true
					else:
						is_finish = false

		if !achieve_item.is_finish && is_finish:
			# 新完成的成就，提示玩家成就已完成
			achieve_item.is_finish = is_finish
			DataManager.player_achievement_is_finish_data.set(achieve_item.name, is_finish)
			return achieve_item
	return null
