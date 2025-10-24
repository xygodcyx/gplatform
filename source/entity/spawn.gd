@tool
class_name Spawn extends Node2D

@onready var marker_2d: Marker2D = $Marker2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var parent_node: Node2D = get_parent()
@export var init_flip_h: bool = false:
	set(value):
		init_flip_h = value
		if animated_sprite_2d:
			animated_sprite_2d.flip_h = init_flip_h

var origin_spawn_position: Vector2
var spawned_node: Node2D
var is_init_spawn: bool = true

func _ready() -> void:
	origin_spawn_position = marker_2d.global_position

func spawn(node_pack: PackedScene):
	animated_sprite_2d.play("moving")
	await animated_sprite_2d.animation_finished
	var node: Node2D = node_pack.instantiate()
	node.set("init_flip", init_flip_h)
	node.global_position = get_spawn_point()
	parent_node.add_child(node)
	animated_sprite_2d.play("idle")
	spawned_node = node

func reset_spawn_point():
	set_spawn_point(origin_spawn_position)
	DataManager.player_rebirth_point = get_spawn_point()

func set_spawn_point(new_position: Vector2):
	marker_2d.global_position = new_position

func get_spawn_point():
	return marker_2d.global_position
