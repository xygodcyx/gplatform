@tool
extends Node2D

@onready var ball: CharacterBody2D = $Ball

@export var chain_texture: Texture2D = preload("res://assets/textures/traps/Spiked Ball/Chain.png")
@export var chain_width: float = 10.0
@export var init_angle: float  = 90.0
@export var swing_angle: float = 45.0
@export var swing_speed: float = 1.0
@export var is_loop: bool = true
@export var is_editor: bool = false

var time := 0.0

var chains: Array[Sprite2D] = []
var radius: float

func _ready() -> void:
	init_chains()

func _process(delta: float) -> void:
	if is_editor: return
	time += delta * swing_speed
	var angle = deg_to_rad(sin(time) * swing_angle) + deg_to_rad(init_angle)
	update_ball_position(angle)
	update_chain_display()

func init_chains():
	radius = ball.global_position.distance_to(global_position)
	var points = radius / chain_width
	for point in points:
		var chain = Sprite2D.new()
		chain.texture = chain_texture
		add_child(chain)
		chains.push_back(chain)
	update_chain_display()


func update_ball_position(angle: float):
	ball.global_position = Vector2(
		global_position.x + radius * cos(angle),
		global_position.y + radius * sin(angle)
	)

func update_chain_display():
	var index = 0
	for chain in chains:
		chain.global_position = global_position + index * chain_width * global_position.direction_to(ball.global_position)
		index += 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var player = body as Player
		player.injure(self)
