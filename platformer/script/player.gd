extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

@export var MAX_JUMP = 2

@export var DASH_SPEED = 800
@export var DASH_DURATION = 0.2
@export var DASH_COOLDOWN = 1.0

@export var WALL_JUMP_FORCE = -500.0
@export var WALL_JUMP_HORIZONTAL_FORCE = 200.0 # Reduced for smoother wall climbing
@export var WALL_STICK_TIME = 0.1
@export var WALL_SLIDE_SPEED = 100.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
@onready var wall_raycast_left = $WallRayCastLeft
@onready var wall_raycast_right = $WallRayCastRight


var direction = null
var jump_count = 0
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = 0
var is_gliding_wall = false
var wall_stick_timer = 0.0
var wall_slide = 0 # -1 -> left, 1 -> right
var wall_jump_timer = 0.0 # Add this to prevent immediate input override
var WALL_JUMP_INPUT_DELAY = 0.2 # Increased for smoother control


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor() and not is_gliding_wall:
		velocity += get_gravity() * delta
	
	handle_input()
	check_wall_collision()
	handle_dash(delta)
	apply_movement()
	update_animation()
	handle_jump_count()
	move_and_slide()
	
	# Update wall jump timer
	if wall_jump_timer > 0:
		wall_jump_timer -= delta
		

func handle_input():
	direction = Input.get_axis("move_left", "move_right")

	# Only flip sprite if not in wall jump delay
	if direction != 0 and wall_jump_timer <= 0:
		animated_sprite.flip_h = direction < 0
	
	# Wall jump logic
	if Input.is_action_just_pressed("jump"):
		if is_gliding_wall and jump_count < MAX_JUMP:
			perform_wall_jump()
		elif jump_count < MAX_JUMP:
			velocity.y = JUMP_VELOCITY
			jump_count += 1

	if (Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0):
		start_dash()

func perform_wall_jump():
	# Jump away from wall (opposite direction)
	velocity.y = WALL_JUMP_FORCE # Strong upward force
	velocity.x = - wall_slide * WALL_JUMP_HORIZONTAL_FORCE
	animated_sprite.flip_h = wall_slide < 0
	
	jump_count = MAX_JUMP
	is_gliding_wall = false
	wall_jump_timer = WALL_JUMP_INPUT_DELAY # Prevent immediate input override
	wall_stick_timer = WALL_STICK_TIME # Reset stick timer for next wall

func handle_dash(delta):
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_cooldown_timer = DASH_COOLDOWN
	else:
		dash_cooldown_timer -= delta
		dash_cooldown_timer = max(0, dash_cooldown_timer)

func start_dash():
	is_dashing = true
	dash_timer = DASH_DURATION
	
	# Determine dash direction
	if direction != 0:
		dash_direction = direction
	elif animated_sprite.flip_h:
		dash_direction = -1
	else:
		dash_direction = 1
	

	velocity.x = dash_direction * DASH_SPEED
	if velocity.y > 0: # Only if falling
		velocity.y = min(velocity.y, -50)

func update_animation():
	if is_dashing:
		animated_sprite.play("dash")
	elif direction == 0:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")

func handle_jump_count():
	if is_on_floor():
		jump_count = 0
		is_gliding_wall = false

func apply_movement():
	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
		if dash_timer < 0.1:
			velocity.x = move_toward(velocity.x, 0, DASH_SPEED * 10 * get_physics_process_delta_time())
	
	# Don't override velocity during wall jump delay
	elif wall_jump_timer > 0:
		# Minimal air control during wall jump to maintain momentum
		if direction != 0:
			velocity.x += direction * SPEED * 0.1 * get_physics_process_delta_time()
			# Allow wider range for wall jumping
			velocity.x = clamp(velocity.x, -SPEED * 2, SPEED * 2)
	
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

func check_wall_collision():
	is_gliding_wall = false
	wall_slide = 0
	
	# Check left wall
	if wall_raycast_left.is_colliding() and not is_on_floor():
		is_gliding_wall = true
		wall_slide = -1
		jump_count = 0

	# Check right wall
	elif wall_raycast_right.is_colliding() and not is_on_floor():
		is_gliding_wall = true
		wall_slide = 1
		jump_count = 0

	
	# Handle wall sticking
	if is_gliding_wall:
		wall_stick_timer -= get_physics_process_delta_time()
		if wall_stick_timer <= 0:
			# Apply wall slide
			velocity.y = WALL_SLIDE_SPEED
	else:
		wall_stick_timer = WALL_STICK_TIME