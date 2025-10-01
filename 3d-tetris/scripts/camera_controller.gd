extends Node3D

var camera_angle = 0
var target_angle = 0
var is_rotating = false
var is_top_down = false

@export var grid_width = 10
@export var grid_height = 25
@export var grid_depth = 10
@export var grid_size = 1
@export var rotation_duration = 0.5  # Duration in seconds for smooth rotation

var camera: Camera3D
var tween: Tween

func _ready():
	camera = Camera3D.new()
	add_child(camera)
	update_camera_position()

func update_camera_position():
	var grid_center = Vector3(
		(grid_width * grid_size - grid_size) / 2.0,
		(grid_height * grid_size) * 1.1,
		(grid_depth * grid_size - grid_size) / 1.5
	)
	
	if is_top_down:
		# Top-down view
		var top_down_height = grid_height * grid_size * 0.9
		camera.global_position = Vector3(
			grid_center.x,
			top_down_height,
			grid_center.z
		)
		camera.look_at(Vector3(grid_center.x, 0, grid_center.z), Vector3(0, 0, -1))
	else:
		# Normal orbital view
		var camera_distance = max(grid_width, grid_depth) * 1.0
		var angle_rad = deg_to_rad(camera_angle)
		
		camera.global_position = Vector3(
			grid_center.x + sin(angle_rad) * camera_distance,
			grid_center.y,
			grid_center.z + cos(angle_rad) * camera_distance
		)
		
		camera.look_at(Vector3(grid_center.x, grid_center.y - camera_distance, grid_center.z), Vector3.UP)

func smooth_rotate_to_angle(new_angle: float):
	if is_rotating and tween:
		tween.kill()  # Stop any existing rotation
	
	target_angle = new_angle
	is_rotating = true
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "camera_angle", target_angle, rotation_duration)
	tween.tween_callback(func(): is_rotating = false)

func _process(_delta):
	if is_rotating:
		update_camera_position()

func rotate_left():
	if is_rotating:
		return  # Prevent multiple rotations at once
	
	var new_angle = camera_angle - 90
	if new_angle < 0:
		new_angle = 270
	smooth_rotate_to_angle(new_angle)

func rotate_right():
	if is_rotating:
		return  # Prevent multiple rotations at once
	
	var new_angle = camera_angle + 90
	if new_angle >= 360:
		new_angle = 0
	smooth_rotate_to_angle(new_angle)

func camera_rotation():
	# Check if both keys are pressed simultaneously for top-down view
	if Input.is_action_just_pressed("camera_rotate_left") and Input.is_action_pressed("camera_rotate_right"):
		toggle_top_down()
	elif Input.is_action_just_pressed("camera_rotate_right") and Input.is_action_pressed("camera_rotate_left"):
		toggle_top_down()
	elif Input.is_action_just_pressed("camera_rotate_left") and not is_top_down:
		rotate_left()
	elif Input.is_action_just_pressed("camera_rotate_right") and not is_top_down:
		rotate_right()

func get_camera_angle() -> int:
	return int(target_angle if is_rotating else camera_angle)

func toggle_top_down():
	if is_rotating and tween:
		tween.kill()
	
	is_top_down = not is_top_down
	is_rotating = true
	
	# Animate the transition
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# We don't tween a specific property, just trigger the visual update
	tween.tween_callback(update_camera_position).set_delay(0.0)
	tween.tween_interval(rotation_duration)
	tween.tween_callback(func(): is_rotating = false)
