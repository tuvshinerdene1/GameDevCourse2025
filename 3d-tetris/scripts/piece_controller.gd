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
		
		# Get actual camera direction vectors
		var camera = get_viewport().get_camera_3d()
		var camera_forward = -camera.global_transform.basis.z
		var camera_right = camera.global_transform.basis.x
		
		# Flatten to horizontal plane
		camera_forward.y = 0
		camera_forward = camera_forward.normalized()
		camera_right.y = 0
		camera_right = camera_right.normalized()
		
		# Check if we're in top-down view by looking at camera's Y position relative to grid
		var is_top_down = camera_controller.is_top_down if camera_controller else false
		
		# Adjust directions based on view mode
		if Input.is_action_pressed("move_down"):
			if is_top_down:
				new_pos += camera_forward * grid_management.grid_size
			else:
				new_pos -= camera_forward * grid_management.grid_size
			moved = true
		elif Input.is_action_pressed("move_up"):
			if is_top_down:
				new_pos -= camera_forward * grid_management.grid_size
			else:
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
# piece_controller.gd - Updated rotate function with wall kicks
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
		
		if Input.is_action_just_pressed("rotate_up"):
			rotation_axis = -camera_right
			rotated = true
		elif Input.is_action_just_pressed("rotate_down"):
			rotation_axis = camera_right
			rotated = true
		elif Input.is_action_just_pressed("rotate_left"):
			rotation_axis = -camera_forward
			rotated = true
		elif Input.is_action_just_pressed("rotate_right"):
			rotation_axis = camera_forward
			rotated = true
		
		if rotated:
			var original_rotation = rotation
			var original_position = global_position
			rotate(rotation_axis, deg_to_rad(90))
			
			rotation_degrees.x = round(rotation_degrees.x / 90) * 90
			rotation_degrees.y = round(rotation_degrees.y / 90) * 90
			rotation_degrees.z = round(rotation_degrees.z / 90) * 90
			
			# Try the rotation at current position first
			if grid_management.can_rotate_to(self, rotation_degrees):
				time_since_last_rotate = 0
			else:
				# Wall kick attempts - try offsetting in different directions
				var wall_kick_offsets = [
					Vector3(1, 0, 0) * grid_management.grid_size,   # Right
					Vector3(-1, 0, 0) * grid_management.grid_size,  # Left
					Vector3(0, 0, 1) * grid_management.grid_size,   # Forward
					Vector3(0, 0, -1) * grid_management.grid_size,  # Back
					Vector3(1, 0, 1) * grid_management.grid_size,   # Diagonal
					Vector3(-1, 0, 1) * grid_management.grid_size,
					Vector3(1, 0, -1) * grid_management.grid_size,
					Vector3(-1, 0, -1) * grid_management.grid_size,
					Vector3(0, 1, 0) * grid_management.grid_size,   # Up
					Vector3(2, 0, 0) * grid_management.grid_size,   # 2 blocks right
					Vector3(-2, 0, 0) * grid_management.grid_size,  # 2 blocks left
				]
				
				var kick_successful = false
				for offset in wall_kick_offsets:
					global_position = original_position + offset
					if grid_management.can_rotate_to(self, rotation_degrees):
						time_since_last_rotate = 0
						kick_successful = true
						break
				
				if not kick_successful:
					# Revert both rotation and position
					rotation = original_rotation
					global_position = original_position
func move_down(grid_size: float) -> bool:
	var new_pos = global_position + Vector3(0, -1, 0) * grid_size
	if grid_management.can_move_to(new_pos):
		global_position = new_pos
		return true
	else:
		piece_landed.emit()
		return false
