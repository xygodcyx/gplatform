class_name End extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var gpuparticles_2d: GPUParticles2D = $AnimatedSprite2D/GPUParticles2D

var can_end: bool = false

func _ready() -> void:
	SignalManager.need_collected_fruit_count_change.connect(
		func(_count):
			check_can_end(DataManager.collected_count)
	)
	
	SignalManager.collected_count_change.connect(
		func(count):
			check_can_end(count)
	)

func check_can_end(count: int):
	if count >= DataManager.need_collected_fruit_count:
		can_end = true
		gpuparticles_2d.emitting = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if can_end and (body is Player):
		AudioManager.play_sfx_big_egg_collect()
		# animated_sprite_2d.play("moving")
		# await animated_sprite_2d.animation_finished
		SignalManager.player_touch_end.emit()