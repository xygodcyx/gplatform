class_name AchievementCondition extends Resource

@export_enum(\
"achieve_deaden_count", \
"achieve_pass_game_count", \
"achieve_replaying_count", \
"achieve_collected_count", \
)
var check_prop: String

@export_enum(\
">=", \
">", \
"<=", \
"<", \
"==", \
)
var operator: String = ">="

@export var operand: int = 1
