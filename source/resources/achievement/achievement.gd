class_name Achievement extends Resource

@export var name: String
@export var desc: String
@export var condition: Array[AchievementCondition] = [
    # 是否已完成 ,属性，操作符，操作数
]

var is_finish: bool = false