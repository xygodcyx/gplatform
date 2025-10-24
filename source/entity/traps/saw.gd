class_name Saw extends PathFollow2D

@export var is_reversal : bool = false
@export var anim_reversal : bool = true
@export var speed: float = 50
var need_reversal : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if anim_reversal :
		$AnimatedSprite2D.play_backwards("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_reversal :
		if progress_ratio >= 0.99:
			need_reversal = true
		elif progress_ratio <= 0.01:
			need_reversal = false
		progress += delta *  speed * (1 if ! need_reversal else -1)
	
	if !is_reversal:
		progress += delta * speed


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var player = body as Player
		player.injure(self)
