extends Node3D

signal piece_landed

@export var move_interval_hor: float = 0.09
@export var rotate_interval: float = 0.2

var grid_management: GridManager
var time_since_last_move_hor: float = 0.0
var time_since_last_rotate: float = 0.0
var camera_controller: Node

func setup(grid_mgr: GridManager, cam_controller: Node):
	grid_management = grid_mgr
	camera_controller = cam_controller

func process_movement(delta: float):
	_move_horizontally(delta)
	_rotate(delta)

func _move_horizontally(delta):
	time_since_last_move_hor += delta
	if time_since_last_move_hor >= move_interval_hor:
		var moved = false
		var new_pos = global_position
		
		var camera_angle = camera_controller.get_camera_angle()
		var angle_rad = deg_to_rad(camera_angle)
		var camera_forward = Vector3(-sin(angle_rad), 0, -cos(angle_rad))
		var camera_right = Vector3(cos(angle_rad), 0, -sin(angle_rad))
		
		if Input.is_action_pressed("move_down"):
			new_pos -= camera_forward * grid_management.grid_size
			moved = true
		elif Input.is_action_pressed("move_up"):
			new_pos += camera_forward * grid_management.grid_size
			moved = true
		elif Input.is_action_pressed("move_right"):
			new_pos += camera_right * grid_management.grid_size
			moved = true
		elif Input.is_action_pressed("move_left"):
			new_pos -= camera_right * grid_management.grid_size
			moved = true
		
		if moved and grid_management.can_move_to(new_pos):
			global_position = new_pos
			time_since_last_move_hor = 0

func _rotate(delta: float):
	time_since_last_rotate += delta
	if time_since_last_rotate >= rotate_interval:
		var rotated = false
		var rotation_axis = Vector3.ZERO
		
		var camera = get_viewport().get_camera_3d()
		var camera_forward = -camera.global_transform.basis.z
		var camera_right = camera.global_transform.basis.x
		
		camera_forward.y = 0
		camera_forward = camera_forward.normalized()
		camera_right.y = 0
		camera_right = camera_right.normalized()
		
		if Input.is_action_just_pressed("rotate_up"):  # Flip away from camera
			rotation_axis = -camera_right
			rotated = true
		elif Input.is_action_just_pressed("rotate_down"):  # Flip towards camera
			rotation_axis = camera_right
			rotated = true
		elif Input.is_action_just_pressed("rotate_left"):  # Flip left (screen-relative)
			rotation_axis = -camera_forward
			rotated = true
		elif Input.is_action_just_pressed("rotate_right"):  # Flip right (screen-relative)
			rotation_axis = camera_forward
			rotated = true
		
		if rotated:
			var original_rotation = rotation
			rotate(rotation_axis, deg_to_rad(90))
			
			rotation_degrees.x = round(rotation_degrees.x / 90) * 90
			rotation_degrees.y = round(rotation_degrees.y / 90) * 90
			rotation_degrees.z = round(rotation_degrees.z / 90) * 90
			
			if grid_management.can_rotate_to(self, rotation_degrees):
				time_since_last_rotate = 0
			else:
				rotation = original_rotation

func move_down(grid_size: float) -> bool:
	var new_pos = global_position + Vector3(0, -1, 0) * grid_size
	if grid_management.can_move_to(new_pos):
		global_position = new_pos
		return true
	else:
		piece_landed.emit()
		return false
