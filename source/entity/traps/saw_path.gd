@tool
extends Path2D

@export var texture: Texture2D
@export var show_chain: bool = true
@export var chain_width : float = 10.0


func _ready() -> void:
	show_chain_display()
	
func show_chain_display():
	if not show_chain:
		return

	var points:float = curve.get_baked_length() / chain_width
	for point in points:
		var baked = curve.sample_baked(point * chain_width)
		var chain = Sprite2D.new()
		chain.texture = texture
		chain.position = baked
		add_child(chain)
		
