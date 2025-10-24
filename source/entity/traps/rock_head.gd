extends CharacterBody2D

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var speed = 200.0
@export var directions: Array[Direction]

var speed_scale: float = 1.0

var move_index: int = 0
var direction_vectors: Array[Vector2]
var direction: Vector2 = Vector2.ZERO
var collision_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	init_direction_vectors()
	idle()
	

func _physics_process(delta: float) -> void:
	var collision: KinematicCollision2D = move_and_collide(delta * direction * speed * speed_scale)
	if direction != Vector2.ZERO:
		speed_scale += delta * 2
	else:
		speed_scale = 1
	
	if collision:
		handle_collision(collision)

func handle_collision(collision: KinematicCollision2D):
	collision_direction = collision.get_normal()
	hit()

func hit():
	direction = Vector2.ZERO
	match collision_direction:
		Vector2.UP:
			animation_player.play("bottom_hit")
		Vector2.DOWN:
			animation_player.play("top_hit")
		Vector2.LEFT:
			animation_player.play("right_hit")
		Vector2.RIGHT:
			animation_player.play("left_hit")
	await animation_player.animation_finished
	idle()

func idle():
	direction = Vector2.ZERO
	animation_player.play("idle")
	await animation_player.animation_finished
	move()

func move():
	if direction_vectors.is_empty(): return
	animation_player.play("blink")
	direction = direction_vectors[move_index]
	move_index = (move_index + 1) % direction_vectors.size()

func init_direction_vectors():
	if directions.is_empty(): return
	for _direction in directions:
		var vector: Vector2 = Vector2.ZERO
		match _direction:
			Direction.UP:
				vector = Vector2.UP
			Direction.DOWN:
				vector = Vector2.DOWN
			Direction.LEFT:
				vector = Vector2.LEFT
			Direction.RIGHT:
				vector = Vector2.RIGHT
		direction_vectors.push_back(vector)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var player = body as Player
		player.injure(self)
