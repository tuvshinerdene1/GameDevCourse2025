extends CharacterBody2D

@export var SPEED := 300.0
@export var JUMP_VELOCITY := -400.0

@export var ACCELERATION_DURATION := 0.5
@export var DECCELERATION_DURATION := 0.3

@export var MAX_JUMP := 2
@export var COYOTE_TIME := 0.2
@export var JUMP_HOLD_TIME := 0.25

@export var DASH_SPEED := 800
@export var DASH_DURATION := 0.2
@export var DASH_COOLDOWN := 1.0

@export var WALL_JUMP_FORCE := -500.0
@export var WALL_JUMP_HORIZONTAL_FORCE := 200.0
@export var WALL_STICK_TIME := 0.1
@export var WALL_SLIDE_SPEED := 100.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
@onready var wall_raycast_left = $WallRayCastLeft
@onready var wall_raycast_right = $WallRayCastRight


var direction := 0.0
var jump_count := 0

var is_dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := 0

var is_gliding_wall := false
var wall_stick_timer := 0.0
var wall_slide := 0 # -1 -> left, 1 -> right
var wall_jump_timer := 0.0
const WALL_JUMP_INPUT_DELAY := 0.2

var _accel: float
var _decel: float

var _coyote_timer := 0.0
var _jump_hold_timer := 0.0
var _jump_just_pressed := false

func _ready():
	_accel = SPEED / ACCELERATION_DURATION
	_decel = SPEED / DECCELERATION_DURATION

func _physics_process(delta: float) -> void:
	handle_input()
	check_wall_collision()
	apply_gravity(delta)
	set_coyote_timer(delta)
	handle_dash(delta)
	apply_movement()
	update_animation()
	handle_jump_count()
	move_and_slide()
	handle_wall_jump_timer(delta)
	
	_jump_just_pressed = false

# =============================================================================
#                                INPUT & JUMP
# =============================================================================
func handle_input():
	direction = Input.get_axis("move_left", "move_right")

	if direction != 0 and wall_jump_timer <= 0:
		animated_sprite.flip_h = direction < 0

	if Input.is_action_just_pressed("jump"):
		_jump_just_pressed = true

		# Ground or coyote jump (doesn't consume air jump)
		if _coyote_timer > 0:
			jump()
			_coyote_timer = 0 # Consume coyote time
		# Air jump (consumes from MAX_JUMP)
		elif jump_count < MAX_JUMP:
			jump()
		# Wall jump
		elif is_gliding_wall:
			perform_wall_jump()

	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0:
		start_dash()

func jump():
	velocity.y = JUMP_VELOCITY
	# Only increment jump_count if we're already in the air (not using coyote)
	if _coyote_timer <= 0:
		jump_count += 1
	_jump_hold_timer = JUMP_HOLD_TIME

# =============================================================================
#                                GRAVITY & JUMP HOLD
# =============================================================================
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	# Variable jump height
	if _jump_just_pressed:
		pass
	elif Input.is_action_pressed("jump") and velocity.y < 0 and _jump_hold_timer > 0:
		var hold_factor = _jump_hold_timer / JUMP_HOLD_TIME
		velocity.y += gravity * delta * (1.0 - hold_factor * 0.8)
	else:
		pass

	# Wall slide cap
	if is_gliding_wall and wall_stick_timer <= 0 and velocity.y > WALL_SLIDE_SPEED:
		velocity.y = WALL_SLIDE_SPEED

# =============================================================================
#                              COYOTE & JUMP HOLD TIMER
# =============================================================================
func set_coyote_timer(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = COYOTE_TIME
	else:
		_coyote_timer = max(_coyote_timer - delta, 0)

	if _jump_just_pressed:
		_jump_hold_timer = JUMP_HOLD_TIME
	elif not Input.is_action_pressed("jump"):
		_jump_hold_timer = max(_jump_hold_timer - delta, 0)

# =============================================================================
#                              WALL JUMP
# =============================================================================
func perform_wall_jump():
	velocity.y = WALL_JUMP_FORCE
	velocity.x = - wall_slide * WALL_JUMP_HORIZONTAL_FORCE
	animated_sprite.flip_h = wall_slide < 0
	
	is_gliding_wall = false
	jump_count = 0 # Reset jump count on wall jump
	wall_jump_timer = WALL_JUMP_INPUT_DELAY
	wall_stick_timer = WALL_STICK_TIME
	_jump_hold_timer = JUMP_HOLD_TIME

# =============================================================================
#                              WALL COLLISION
# =============================================================================
func check_wall_collision():
	is_gliding_wall = false
	wall_slide = 0
	wall_stick_timer = max(wall_stick_timer - get_physics_process_delta_time(), 0)
	
	if wall_raycast_left.is_colliding() and not is_on_floor() and direction <= 0:
		is_gliding_wall = true
		wall_slide = -1
		wall_stick_timer = WALL_STICK_TIME
	elif wall_raycast_right.is_colliding() and not is_on_floor() and direction >= 0:
		is_gliding_wall = true
		wall_slide = 1
		wall_stick_timer = WALL_STICK_TIME

# =============================================================================
#                              DASH
# =============================================================================
func handle_dash(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown_timer = DASH_COOLDOWN
	else:
		dash_cooldown_timer = max(dash_cooldown_timer - delta, 0)

func start_dash():
	is_dashing = true
	dash_timer = DASH_DURATION
	
	dash_direction = direction if direction != 0 else (-1 if animated_sprite.flip_h else 1)
	velocity.x = dash_direction * DASH_SPEED
	if velocity.y > 0:
		velocity.y = min(velocity.y, -50)

# =============================================================================
#                              MOVEMENT & ANIM
# =============================================================================
func apply_movement():
	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
		if dash_timer < 0.1:
			velocity.x = move_toward(velocity.x, 0, DASH_SPEED * 10 * get_physics_process_delta_time())
		return
	
	if wall_jump_timer > 0:
		if direction != 0:
			velocity.x += direction * SPEED * 0.1 * get_physics_process_delta_time()
			velocity.x = clamp(velocity.x, -SPEED * 2, SPEED * 2)
		return

	var target_speed := direction * SPEED
	var rate := _accel if direction != 0 else _decel
	velocity.x = move_toward(velocity.x, target_speed, rate * get_physics_process_delta_time())

func update_animation():
	if is_dashing:
		animated_sprite.play("dash")
	elif abs(velocity.x) < 10:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")

func handle_jump_count():
	if is_on_floor():
		jump_count = 0
		is_gliding_wall = false

func handle_wall_jump_timer(delta: float) -> void:
	if wall_jump_timer > 0:
		wall_jump_timer -= delta