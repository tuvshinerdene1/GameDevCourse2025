extends CharacterBody2D

@export var SPEED := 150.0
@export var ACCELERATION_DURATION := 0.3
@export var DECCELERATION_DURATION := 0.3

@export var JUMP_VELOCITY := -250.0
@export var JUMP_CUTOFF := -50.0
@export var COYOTE_TIME := 0.15
@export var JUMP_BUFFER := 0.15

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var was_on_floor := false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D

var direction := 0.0
var accel: float
var decel: float

func _ready():
	accel = SPEED / ACCELERATION_DURATION
	decel = SPEED / DECCELERATION_DURATION

func _physics_process(delta: float):
	apply_gravity(delta)
	handle_jump(delta)
	handle_input()
	apply_horizontal_movement(delta)
	move_and_slide()
	update_animation()

func handle_jump(delta):
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	elif coyote_timer > 0:
		coyote_timer -= delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0
	if Input.is_action_just_released("jump") and velocity.y < JUMP_CUTOFF:
		velocity.y = JUMP_CUTOFF
	

func handle_input():
	direction = 0
	if Input.is_action_pressed("move_right"):
		direction = 1
	elif Input.is_action_pressed("move_left"):
		direction = -1

	# Flip sprite
	if direction != 0:
		animated_sprite.flip_h = direction < 0

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func apply_horizontal_movement(delta: float):
	var target_speed := direction * SPEED
	var rate := accel if direction != 0 else decel
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)

func update_animation():
	if not is_on_floor():
		pass
	elif abs(velocity.x) < 5:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")
