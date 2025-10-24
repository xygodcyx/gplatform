extends Node


# 场景切换相关
signal go_menu

signal go_rank

signal go_achievement

signal go_choose_level

signal go_choose_character

signal go_level(level_index)

signal go_setting

signal exit_game

signal reload_cur_level_scene(force_level_index)

signal deaden_reload_cur_level_scene(force_level_index)

signal go_replaying_level(cur_record_id, cur_level_index, cur_character_index)


# 玩家收集相关
signal collected_count_change(count)

signal need_collected_fruit_count_change(count)

signal achieve_prop_value_change

# 玩家相关
signal move_direction(direction)

signal down

signal jump_start

signal jump_end

signal player_injure()

signal hp_change(hp)

signal max_hp_change(hp)

signal shield_change(shield)

signal max_shield_count_change(shield)

signal deaden

signal player_animation_finish

signal player_touch_end()

signal player_win(level_index, is_replaying)

signal select_player_index_change(player_index)

# 设置相关

signal volume_change(volume)

signal lang_index_change(lang_index)

# 保存相关

signal save_data_complete

# 游戏进程相关

signal game_time_update(time)

signal playback_action_change(action_name)

# 游戏UI相关

signal dispatch_info(title, desc, icon)

signal open_pass_panel
signal close_pass_panel

signal open_more_panel
signal close_more_panel

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS

func connect_signal(will_connect_signal: Signal, callable: Callable):
    if will_connect_signal.is_connected(callable):
        will_connect_signal.disconnect(callable)
        will_connect_signal.connect(callable)
    else:
        will_connect_signal.connect(callable)