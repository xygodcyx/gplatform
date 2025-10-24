extends Node2D

@onready var marker_2d: Marker2D = $Marker2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var can_set_flag = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !can_set_flag || !(body is Player): return
	DataManager.player_rebirth_point = marker_2d.global_position
	animated_sprite_2d.play("moving")
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")
	can_set_flag = false
