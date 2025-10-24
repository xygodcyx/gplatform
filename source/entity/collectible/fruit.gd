class_name Fruit extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var flash: AnimatedSprite2D = $Flash

enum Type {
	RANDOM,
	APPLE,
	BANANAS,
	CHERRIES,
	KIWI,
	MELON,
	ORANGE,
	PINEAPPLE,
	STRAWBERRY,
}

@export var fruit_type: Type = Type.RANDOM

const textures: Array[Texture2D] = [
	preload("res://assets/textures/items/texture_items_fruits_apple.png"),
	preload("res://assets/textures/items/texture_items_fruits_bananas.png"),
	preload("res://assets/textures/items/texture_items_fruits_cherries.png"),
	preload("res://assets/textures/items/texture_items_fruits_kiwi.png"),
	preload("res://assets/textures/items/texture_items_fruits_melon.png"),
	preload("res://assets/textures/items/texture_items_fruits_orange.png"),
	preload("res://assets/textures/items/texture_items_fruits_pineapple.png"),
	preload("res://assets/textures/items/texture_items_fruits_strawberry.png"),
]

var has_collected: bool = false

func _ready() -> void:
	sprite_2d.texture = textures[fruit_type - 1 if fruit_type else randi_range(0, textures.size() - 1)]


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !has_collected and body.is_in_group("Player"):
		var player = body as Player
		player.collect(self)
		sprite_2d.hide()
		flash.show()
		flash.play("idle")
		has_collected = true
		AudioManager.play_sfx_fruit_collect()
		flash.animation_finished.connect(
			func():
				self.queue_free()
		)
