# OrbMagnet.gd
extends Area2D

@export var pull_radius: float = 120.0          # Visual + detection range
@export var snap_zone: float = 40.0             # Float-to-center zone
@export var bounce_force: float = 500.0         # Same-charge pushback
@export var launch_speed: float = 700.0         # How fast you fly out
@export var upward_launch_bonus: float = 150.0  # Extra lift on no-input launch

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $PullParticles
@onready var sfx_pull: AudioStreamPlayer2D = $SFX_Pull
@onready var sfx_bounce: AudioStreamPlayer2D = $SFX_Bounce
@onready var sfx_launch: AudioStreamPlayer2D = $SFX_Launch

var player: CharacterBody2D = null
var is_player_inside: bool = false
var was_charge_flipped: bool = false

func _ready() -> void:
	# Setup collision
	var shape = CircleShape2D.new()
	shape.radius = pull_radius
	collision_shape.shape = shape
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("get_charge"):
		player = body
		is_player_inside = true
		particles.emitting = true
		sfx_pull.play()

func _on_body_exited(body: Node) -> void:
	if body == player:
		player = null
		is_player_inside = false
		particles.emitting = false
		sfx_pull.stop()
		was_charge_flipped = false

func _physics_process(delta: float) -> void:
	if not player or not is_player_inside:
		return
	
	var player_charge = player.get("charge")
	var orb_charge_sign = sign(charge)
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	
	# === 1. OPPOSITE CHARGE → FLOAT TO CENTER ===
	if player_charge != 0 and orb_charge_sign != 0 and orb_charge_sign != player_charge:
		if dist > snap_zone:
			# Smooth float-in
			var pull_dir = to_player.normalized()
			player.global_position += pull_dir * 300.0 * delta
		else:
			# Snap to center
			player.global_position = global_position
			_check_charge_flip()
	
	# === 2. SAME CHARGE → BOUNCY PUSHBACK ===
	elif player_charge != 0 and orb_charge_sign == player_charge:
		if dist < pull_radius * 0.7:
			var push_dir = to_player.normalized()
			player.velocity = push_dir * bounce_force
			player.global_position += push_dir * 20
			sfx_bounce.play()
			_bounce_effect()
	
	# === 3. NEUTRAL → PHASE THROUGH (do nothing) ===
	# → No code needed! Player just walks through.

func _check_charge_flip() -> void:
	if not was_charge_flipped and Input.is_action_just_pressed("positive_current"):
		was_charge_flipped = true
		_launch_player()
	elif not was_charge_flipped and Input.is_action_just_pressed("negative_current"):
		was_charge_flipped = true
		_launch_player()

func _launch_player() -> void:
	var input_dir = Vector2(
		Input.get_action_s trength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	var launch_dir: Vector2
	
	if input_dir.length() > 0.1:
		# 8-way directional launch
		launch_dir = input_dir.normalized()
	else:
		# Default: upward
		launch_dir = Vector2.UP
	
	# Add upward bonus if no horizontal input
	if abs(input_dir.x) < 0.1:
		launch_dir.y = -1.0
		player.velocity = launch_dir * (launch_speed + upward_launch_bonus)
	else:
		player.velocity = launch_dir * launch_speed
	
	sfx_launch.play()
	_spawn_launch_particles(launch_dir)
	_screen_shake(0.3)
	
	# Reset after launch
	player = null
	is_player_inside = false
	particles.emitting = false
	await get_tree().create_timer(0.1).timeout
	was_charge_flipped = false

# ——— VISUAL JUICE ———
func _bounce_effect():
	sprite.scale = Vector2(1.4, 0.8)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1,1), 0.2).set_ease(Tween.EASE_OUT)

func _spawn_launch_particles(dir: Vector2):
	var burst = preload("res://Effects/LaunchBurst.tscn").instantiate()
	burst.global_position = global_position
	burst.rotation = dir.angle()
	get_parent().add_child(burst)

func _screen_shake(intensity: float):
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(intensity)