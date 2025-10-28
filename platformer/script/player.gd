extends CharacterBody2D

@export var SPEED := 150.0
@export var ACCELERATION_DURATION := 0.3
@export var DECCELERATION_DURATION := 0.3
@export var JUMP_VELOCITY := -250.0
@export var JUMP_CUTOFF := -50.0
@export var COYOTE_TIME := 0.15
@export var JUMP_BUFFER := 0.15
@export var AIR_MOVEMENT_DECREASE := 0.7
@export var wall_glide_slow := 0.4
@export var wall_jump_vertical := -250.0
@export var wall_jump_horizontal := 200.0
@export var wall_jump_cutoff := 100.0
@export var wall_jump_gravity_reduction := 0.5
@export var oxygen_gliding_decrease := 0.5
@export var oxygen_decrease_rate := 50.0
@export var oxygen_regen_rate := 30.0
@export var max_fall_speed := 500.0

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var was_on_floor := false
var oxygen := 100.0
var is_gliding_wall := false
var wall_slide := 0 # -1 left, 1 right
var wall_jump_lockout := 0.0 # Prevents immediate wall re-grab
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 0.85
var charge := 0

@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_left = $WallRayCastLeft
@onready var ray_cast_right = $WallRayCastRight
@onready var label = $Label

var direction := 0.0
var accel: float
var decel: float
var is_gliding := false

func _ready():
	accel = SPEED / ACCELERATION_DURATION
	decel = SPEED / DECCELERATION_DURATION

func _physics_process(delta: float):
	update_oxygen_label()
	lock_wall_jump(delta)
	check_wall_collision()
	handle_jump(delta)
	apply_gravity(delta)
	change_direction()
	apply_horizontal_movement(delta)
	move_and_slide()
	change_current()
	update_animation()
	track_floor()

func lock_wall_jump(delta):
	if wall_jump_lockout > 0:
		wall_jump_lockout -= delta
func update_oxygen_label():
	label.text = "Oxygen: %d%%" % int(oxygen)

func handle_jump(delta):
	# Coyote time - grace period after leaving ground
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	elif coyote_timer > 0:
		coyote_timer -= delta
	
	# Jump buffer - remember jump presses briefly
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	if jump_buffer_timer > 0 and coyote_timer > 0:
		perform_floor_jump()
	
	# Wall jump
	elif jump_buffer_timer > 0 and is_gliding_wall and wall_jump_lockout <= 0:
		perform_wall_jump()

	# Variable jump height (release early = shorter jump)
	if Input.is_action_just_released("jump"):
		if velocity.y < JUMP_CUTOFF:
			velocity.y = JUMP_CUTOFF
		# Wall jump horizontal cutoff
		elif is_gliding_wall and abs(velocity.x) > wall_jump_cutoff:
			velocity.x = sign(velocity.x) * wall_jump_cutoff

func perform_floor_jump():
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0

func perform_wall_jump():
		velocity.y = wall_jump_vertical
		velocity.x = - wall_slide * wall_jump_horizontal
		jump_buffer_timer = 0
		wall_jump_lockout = 0.2 # Prevent immediate re-grab
		animated_sprite.flip_h = velocity.x < 0
func change_direction():
	direction = Input.get_axis("move_left", "move_right")
	
	# Flip sprite based on movement
	if direction != 0:
		animated_sprite.flip_h = direction < 0

func apply_gravity(delta: float) -> void:
	is_gliding = false
	
	if is_on_floor():
		oxygen = min(100.0, oxygen + oxygen_regen_rate * delta)
		return
	
	var gravity_force = gravity * delta
	
	# Wall gliding
	if is_gliding_wall and velocity.y > 0:
		gravity_force *= wall_glide_slow
		is_gliding = true
	elif not is_gliding_wall and not is_on_floor() and oxygen > 0 and velocity.y > 0:
		if Input.is_action_pressed("jump"):
			gravity_force *= oxygen_gliding_decrease
			oxygen = max(0.0, oxygen - oxygen_decrease_rate * delta)
	
	velocity.y += gravity_force
	# Cap fall speed (terminal velocity)
	velocity.y = min(velocity.y, max_fall_speed)

func apply_horizontal_movement(delta: float):
	var target_speed := direction * SPEED
	var rate := accel if direction != 0 else decel
	
	# Reduce air control when not wall gliding
	if not is_on_floor() and not is_gliding:
		rate *= AIR_MOVEMENT_DECREASE
	
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)

func update_animation():
	if not is_on_floor():
		if is_gliding_wall:
			pass
			#animated_sprite.play("wall_slide")  # Add this animation if available
		#elif velocity.y < 0:
			#animated_sprite.play("jump")  # Add this animation if available
		#else:
			#animated_sprite.play("fall")  # Add this animation if available
	elif abs(velocity.x) < 5:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")

func check_wall_collision():
	is_gliding_wall = false
	
	# Only check walls if not in wall jump lockout
	if wall_jump_lockout > 0:
		return
	
	# Check left wall
	if ray_cast_left.is_colliding() and not is_on_floor() and direction <= 0 and velocity.y > 0:
		is_gliding_wall = true
		wall_slide = -1
	# Check right wall
	elif ray_cast_right.is_colliding() and not is_on_floor() and direction >= 0 and velocity.y > 0:
		is_gliding_wall = true
		wall_slide = 1

func change_current():
	if charge == 0:
		if Input.is_action_just_pressed("negative_current"):
			charge = -1
		elif Input.is_action_just_pressed("positive_current"):
			charge = 1
	elif charge == 1:
			if Input.is_action_just_pressed("negative_current"):
				charge = -1
			elif Input.is_action_just_pressed("positive_current"):
				charge = 0
	elif charge == -1:
			if Input.is_action_just_pressed("negative_current"):
				charge = 0
			elif Input.is_action_just_pressed("positive_current"):
				charge = 1
				
func track_floor():
	was_on_floor = is_on_floor()