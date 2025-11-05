extends CharacterBody2D

@export var SPEED := 150.0
@export var ACCELERATION_DURATION := 0.3
@export var DECCELERATION_DURATION := 0.3
@export var JUMP_VELOCITY := -250.0
@export var JUMP_CUTOFF := -50.0
@export var COYOTE_TIME := 0.15
@export var JUMP_BUFFER := 0.15
@export var WALL_JUMP_BUFFER := 0.25  # Longer buffer for wall jumps
@export var WALL_COYOTE_TIME := 0.2  # Grace period after leaving wall
@export var AIR_MOVEMENT_DECREASE := 0.7
@export var wall_glide_slow := 0.4
@export var wall_jump_vertical := -250.0
@export var wall_jump_horizontal := 200.0
@export var wall_jump_cutoff := 100.0
@export var wall_jump_lockout_duration := 0.15  # Reduced lockout
@export var wall_jump_input_lock := 0.12  # Reduced input lock
@export var max_fall_speed := 500.0
@export var horizontal_momentum := 0.5

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var wall_coyote_timer := 0.0  # Separate coyote time for walls
var was_on_floor := false
var is_gliding_wall := false
var was_gliding_wall := false  # Track previous wall glide state
var wall_slide := 0 # -1 left, 1 right
var last_wall_side := 0  # Remember which wall we were on
var wall_jump_lockout := 0.0 # Prevents immediate wall re-grab
var wall_jump_control_lock := 0.0  # Locks horizontal input after wall jump
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 0.85
var charge := 0
var is_launched := false
var launch_timer := 0.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_left = $WallRayCastLeft
@onready var ray_cast_right = $WallRayCastRight
@onready var label = $Label
@onready var platform_mover = get_tree().get_first_node_in_group("platform_mover")
signal charge_changed(new_charge:int)

var direction := 0.0
var accel: float
var decel: float
var is_gliding := false

func _ready():
	accel = SPEED / ACCELERATION_DURATION
	decel = SPEED / DECCELERATION_DURATION
	add_to_group("player")

func _physics_process(delta: float):
	#update_oxygen_label()
	lock_wall_jump(delta)
	check_wall_collision()

	if is_launched:
		launch_timer -= delta
		if launch_timer <= 0:
			is_launched = false
		move_and_slide()
		return
	
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
	if wall_jump_control_lock > 0:
		wall_jump_control_lock -= delta
	
	# Wall coyote time
	if is_gliding_wall:
		wall_coyote_timer = WALL_COYOTE_TIME
		last_wall_side = wall_slide
	elif wall_coyote_timer > 0:
		wall_coyote_timer -= delta
		
func update_oxygen_label():
	label.text = "Charge: %d%%v " % int(charge)

func handle_jump(delta):
	# Coyote time - grace period after leaving ground
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		# Reset wall jump lockout when landing
		wall_jump_control_lock = 0
	elif coyote_timer > 0:
		coyote_timer -= delta
	
	# Jump buffer - remember jump presses briefly (longer for wall jumps)
	if Input.is_action_just_pressed("jump"):
		# Use longer buffer if near a wall
		if is_gliding_wall or wall_coyote_timer > 0:
			jump_buffer_timer = WALL_JUMP_BUFFER
		else:
			jump_buffer_timer = JUMP_BUFFER
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	# Floor jump - requires coyote time
	if jump_buffer_timer > 0 and coyote_timer > 0:
		perform_floor_jump()
	
	# Wall jump - more forgiving conditions
	elif jump_buffer_timer > 0 and (is_gliding_wall or wall_coyote_timer > 0) and wall_jump_lockout <= 0:
		# Use current wall if gliding, otherwise use remembered wall from coyote time
		var current_wall = wall_slide if is_gliding_wall else last_wall_side
		
		# More lenient direction check - just need to be pressing away OR neutral
		var pressing_away = false
		var pressing_toward = false
		
		if current_wall == -1:  # On left wall
			if Input.is_action_pressed("move_right"):
				pressing_away = true
			elif Input.is_action_pressed("move_left"):
				pressing_toward = true
		elif current_wall == 1:  # On right wall
			if Input.is_action_pressed("move_left"):
				pressing_away = true
			elif Input.is_action_pressed("move_right"):
				pressing_toward = true
		
		# Allow wall jump if pressing away OR not pressing toward wall
		if pressing_away or not pressing_toward:
			perform_wall_jump()

	# Variable jump height (release early = shorter jump)
	if Input.is_action_just_released("jump"):
		if velocity.y < JUMP_CUTOFF:
			velocity.y = JUMP_CUTOFF

func perform_floor_jump():
	velocity.y = JUMP_VELOCITY
	jump_buffer_timer = 0
	coyote_timer = 0

func perform_wall_jump():
	velocity.y = wall_jump_vertical
	velocity.x = -wall_slide * wall_jump_horizontal
	jump_buffer_timer = 0
	coyote_timer = 0  # Prevent floor jump overlap
	wall_jump_lockout = wall_jump_lockout_duration
	wall_jump_control_lock = wall_jump_input_lock
	is_gliding_wall = false  # Stop wall gliding immediately
	animated_sprite.flip_h = velocity.x < 0
		
func change_direction():
	direction = Input.get_axis("move_left", "move_right")
	
	# Flip sprite based on movement (unless locked from wall jump)
	if direction != 0 and wall_jump_control_lock <= 0:
		animated_sprite.flip_h = direction < 0

func apply_gravity(delta: float) -> void:
	is_gliding = false
	
	if is_on_floor():
		return
	
	var gravity_force = gravity * delta
	
	# Wall gliding
	if is_gliding_wall and velocity.y > 0:
		gravity_force *= wall_glide_slow
		is_gliding = true
	
	velocity.y += gravity_force
	# Cap fall speed (terminal velocity)
	velocity.y = min(velocity.y, max_fall_speed)

func apply_horizontal_movement(delta: float):
	var target_speed := direction * SPEED
	var rate := accel if direction != 0 else decel
	
	# Reduce or disable air control during wall jump
	if wall_jump_control_lock > 0:
		# Heavily reduce control during wall jump
		rate *= 0.1
	elif not is_on_floor() and not is_gliding:
		# Normal reduced air control
		rate *= AIR_MOVEMENT_DECREASE
	
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)

func update_animation():
	if charge == 0:
		if abs(velocity.x) < 5:
			animated_sprite.play("static_idle")
		else:
			animated_sprite.play("static_run")
	if charge == 1:
		if abs(velocity.x) < 5:
			animated_sprite.play("positive_idle")
		else:
			animated_sprite.play("positive_run")
	if charge == -1:
		if abs(velocity.x) < 5:
			animated_sprite.play("negative_idle")
		else:
			animated_sprite.play("negative_run")
		

func check_wall_collision():
	var was_gliding = is_gliding_wall
	is_gliding_wall = false
	
	# Only check walls if not in wall jump lockout
	if wall_jump_lockout > 0:
		return
	
	# Check left wall - must be pressing left and falling
	if ray_cast_left.is_colliding() and not is_on_floor() and velocity.y > 0:
		# Allow wall glide if pressing toward wall OR not pressing anything
		if direction <= 0:
			is_gliding_wall = true
			wall_slide = -1
	
	# Check right wall - must be pressing right and falling
	elif ray_cast_right.is_colliding() and not is_on_floor() and velocity.y > 0:
		# Allow wall glide if pressing toward wall OR not pressing anything
		if direction >= 0:
			is_gliding_wall = true
			wall_slide = 1

func change_current():
	var old_charge = charge
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
	if charge != old_charge:
		charge_changed.emit(charge)

func track_floor():
	if is_on_floor() and not was_on_floor:
		velocity.x *= horizontal_momentum
	was_on_floor = is_on_floor()
	
func get_charge() -> int:
	return charge

func set_launched(duration: float) -> void:
	print("islaunched")
	is_launched = true
	launch_timer = duration
	coyote_timer = 0
	jump_buffer_timer = 0
	wall_jump_lockout = wall_jump_lockout_duration
	wall_jump_control_lock = 0
