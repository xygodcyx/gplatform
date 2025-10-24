@tool
extends Parallax2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var texture_rect: TextureRect = $TextureRect

@export var backward:bool
@export var play_speed:float = 1.0
@export var bg_texture:Texture2D

func _ready() -> void:
	if backward: 
		animation_player.play_backwards("bg")
	if bg_texture:
		texture_rect.texture = bg_texture
	animation_player.speed_scale = play_speed
