extends RigidBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		animated_sprite_2d.play("end")
		await get_tree().create_timer(0.3).timeout
		freeze = false
		collision_shape_2d.disabled = true
		await get_tree().create_timer(10).timeout
		queue_free()