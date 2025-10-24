class_name Player extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var state_chart: StateChart = $StateChart
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var gpuparticles_2d: GPUParticles2D = $GPUParticles2D
@onready var explode_particles: GPUParticles2D = $ExplodeParticles

@export var init_buff: CharacterBuff
@export var speed: float = 200.0
@export var jump_velocity: float = -300.0
@export var wall_speed: float = 30.0

const normal_mask = 1 << 0 | 1 << 2 | 1 << 3 | 1 << 4
const one_way_mask = 1 << 0 | 1 << 3 | 1 << 4

var init_flip: bool = false

var cur_jump_count: int = 0
var can_action: bool = false
var has_one_shot_particles: bool = true
var is_invincible: bool = false
var is_hurting: bool = false

var move_direction: float = 0
var is_jump: bool = false
var is_down: bool = false

func _ready() -> void:
	init()
	
	animated_sprite_2d.animation_finished.connect(
		func():
			if animated_sprite_2d.animation == "appearing":
				sprite_2d.show()
				animated_sprite_2d.hide()
				DataManager.is_in_game = true
				can_action = true
				

			if animated_sprite_2d.animation == "desappearing" && DataManager.hp <= 0:
				SignalManager.player_animation_finish.emit(animated_sprite_2d.name)
				SignalManager.deaden_reload_cur_level_scene.emit(LevelManager.will_start_game_index)
				queue_free()
	)
	
	SignalManager.deaden.connect(
		func():
			can_action = false
			sprite_2d.hide()
			animated_sprite_2d.show()
			animated_sprite_2d.play("desappearing")
	)

	SignalManager.move_direction.connect(
		func(direction):
			move_direction = direction
	)

	SignalManager.down.connect(
		func():
			is_down = true
	)

	SignalManager.jump_start.connect(
		func():
			is_jump = true
	)

func init():
	init_player_display()
	# DataManager.init_player_buff(init_buff)

func init_player_display():
	set_flip(init_flip)
	sprite_2d.hide()
	animated_sprite_2d.show()
	animated_sprite_2d.play("appearing")
	# fade_out()

func _process(_delta: float) -> void:
	if DataManager.is_replaying:
		DataManager.replaying_playback()

func _physics_process(delta: float) -> void:
	if not can_action || is_hurting:
		return
	movement();
	check_flip()
	change_state(delta)
	check_one_way()

func apply_playback():
	pass

func movement():
	if move_direction:
		velocity.x = move_direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		gpuparticles_2d.emitting = false
	move_and_slide()

func check_flip():
	if velocity.x != 0:
		set_flip(velocity.x < 0)
		gpuparticles_2d.emitting = true

func set_flip(flip_h: bool = false, flip_v: bool = false):
	sprite_2d.scale.x = -1 if flip_h else 1
	sprite_2d.scale.y = -1 if flip_v else 1

func check_jump():
	if is_jump:
		is_jump = false
		if is_on_wall():
			# 添加瞬时力
			await get_tree().process_frame
			velocity.x = speed * 5 * -sign(sprite_2d.scale.x)
			velocity.y = jump_velocity
			cur_jump_count = 0
			create_explode_particle(3)
		elif cur_jump_count < DataManager.max_jump_count:
			velocity.y = jump_velocity
			state_chart.send_event("jumped")
			cur_jump_count += 1
			create_explode_particle(3)
		

func check_one_way():
	if is_down:
		is_down = false
		collision_mask = one_way_mask
		await get_tree().create_timer(0.2).timeout
		collision_mask = normal_mask

func change_state(delta: float):
	if is_on_wall() and abs(velocity.y) > 0.1:
		velocity.y = min(velocity.y, wall_speed)
		state_chart.send_event("walled")
		create_explode_particle(1)
	elif velocity != Vector2.ZERO:
		state_chart.send_event("moving")
	else:
		state_chart.send_event("idle")
		gpuparticles_2d.emitting = false

	animation_tree["parameters/Move/blend_position"] = sign(velocity.y)

	if is_on_floor():
		state_chart.send_event("grounded")
		velocity.y = 0
		cur_jump_count = 0
		if !has_one_shot_particles:
			create_explode_particle(10)
			has_one_shot_particles = true
	else:
		state_chart.send_event("aired")
		velocity += get_gravity() * delta
		gpuparticles_2d.emitting = false
		has_one_shot_particles = false

func collect(_item: Fruit):
	DataManager.collected_count += 1

func injure(_item):
	if is_invincible: return
	is_invincible = true
	is_hurting = true
	if DataManager.shield_count > 0:
		DataManager.shield_count -= 1
	else:
		DataManager.hp -= 1
	AudioManager.play_sfx_hit_damage()
	if DataManager.hp > 0:
		state_chart.send_event("hited")
		await animation_tree.animation_finished
		state_chart.send_event("hit_end")
		animated_sprite_2d.play("desappearing")
		queue_free()
		is_invincible = false
		is_hurting = false
		

func create_explode_particle(count: int = 6):
	for i in count:
		explode_particles.emit_particle(explode_particles.global_transform, Vector2(0, 1), Color.WHITE, Color.WHITE, 0)

func _on_ground_state_physics_processing(_delta: float) -> void:
	check_jump()

func _on_jump_state_physics_processing(_delta: float) -> void:
	check_jump()

func _on_double_jump_state_physics_processing(_delta: float) -> void:
	check_jump()

func _on_fall_state_physics_processing(_delta: float) -> void:
	check_jump()

func _on_wall_state_physics_processing(_delta: float) -> void:
	check_jump()
