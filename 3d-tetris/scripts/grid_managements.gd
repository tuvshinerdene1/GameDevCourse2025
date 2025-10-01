class_name GridManager extends Node

var grid = []
var grid_width
var grid_height
var grid_depth
var grid_size
var instance = null

func _init(grid_width, grid_height, grid_depth, grid_size, instance, grid):
	self.grid_width = grid_width
	self.grid_height = grid_height
	self.grid_depth = grid_depth
	self.grid_size = grid_size
	self.instance = instance
	self.grid = grid

func grid_position(pos: Vector3) -> Vector3i:
	var snapped = snap_to_grid(pos)
	return Vector3i(snapped.x / grid_size, snapped.y / grid_size, snapped.z / grid_size)

func snap_to_grid(pos: Vector3) -> Vector3:
	return Vector3(
		round(pos.x / grid_size) * grid_size,
		round(pos.y / grid_size) * grid_size,
		round(pos.z / grid_size) * grid_size
	)

func get_piece_local_grid_offsets(piece: Node3D) -> Array:
	var local_offsets = []
	for child in piece.get_children():
		if child is Node3D:
			var local_pos = child.position
			var offset_grid_units = Vector3i(
				round(local_pos.x / grid_size),
				round(local_pos.y / grid_size),
				round(local_pos.z / grid_size)
			)
			local_offsets.append(offset_grid_units)
	return local_offsets
	
func get_piece_grid_positions(piece: Node3D) -> Array:
	var positions = []
	var piece_grid_pos = grid_position(piece.global_position)
	for child in piece.get_children():
		if child is Node3D:
			positions.append(grid_position(child.global_position))
	return positions

func is_any_grid_position_occupied(grid_positions: Array) -> bool:
	for pos in grid_positions:
		if grid.has(pos):
			return true
	return false

func can_move_to(new_pos: Vector3) -> bool:
	var new_piece_positions = get_piece_grid_positions_at_pos(instance, new_pos)
	for pos in new_piece_positions:
		if pos.y < 0 or pos.y >= grid_height or pos.x < 0 or pos.x >= grid_width or pos.z < 0 or pos.z >= grid_depth:
			return false
		if grid.has(pos):
			return false
	return true

func can_rotate_to(node: Node, rotation: Vector3) -> bool:
	var original_rotation = node.rotation_degrees
	var original_position = node.global_position
	node.rotation_degrees = rotation
	node.global_position = snap_to_grid(node.global_position)
	var grid_positions = get_piece_grid_positions(node)
	node.rotation_degrees = original_rotation
	node.global_position = original_position
	for pos in grid_positions:
		if pos.x < 0 or pos.x >= grid_width or pos.z < 0 or pos.z >= grid_depth or pos.y < 0:
			return false
		if grid.has(pos):
			return false
	return true
	
func get_piece_local_positions(piece: Node3D) -> Array:
	var local_positions = []
	for child in piece.get_children():
		if child is Node3D:
			var local_pos = grid_position(child.position)
			local_positions.append(local_pos)
	return local_positions

func get_piece_grid_positions_at_pos(piece: Node3D, target_pos: Vector3) -> Array:
	var positions = []
	var original_position = piece.global_position
	piece.global_position = target_pos
	for child in piece.get_children():
		if child is Node3D:
			positions.append(grid_position(child.global_position))
	piece.global_position = original_position
	return positions

func row_complete_handler() -> Dictionary:
	var completed_layers = []
	var blocks_to_remove = []  # Store grid positions to remove
	var block_positions = []   # Store all grid positions for shifting

	# Check each layer from y=0 to grid_height-1
	for y in range(grid_height):
		var layer_complete = true
		for x in range(grid_width):
			for z in range(grid_depth):
				var check_pos = Vector3i(x, y, z)
				if not grid.has(check_pos):
					layer_complete = false
					break
			if not layer_complete:
				break
		if layer_complete:
			completed_layers.append(y)
			# Collect all positions in this layer to remove
			for x in range(grid_width):
				for z in range(grid_depth):
					blocks_to_remove.append(Vector3i(x, y, z))

	# If no layers are complete, return early
	if completed_layers.is_empty():
		return {"cleared_layers": 0, "blocks_to_remove": [], "shifted_positions": []}


	# Create a new grid excluding the completed layers
	var new_grid = []
	var shifted_positions = []
	
	for pos in grid:
		if not pos in blocks_to_remove:
			# Calculate how many layers below this position were cleared
			var shift_count = 0
			for cleared_y in completed_layers:
				if pos.y > cleared_y:
					shift_count += 1
			
			if shift_count > 0:
				# Create new position shifted down
				var new_pos = Vector3i(pos.x, pos.y - shift_count, pos.z)
				shifted_positions.append({"old_pos": pos, "new_pos": new_pos})
				new_grid.append(new_pos)
			else:
				# Position doesn't need to shift
				new_grid.append(pos)

	# Update the grid
	grid = new_grid

	# Return the number of cleared layers, blocks to remove, and shifted positions
	return {
		"cleared_layers": completed_layers.size(),
		"blocks_to_remove": blocks_to_remove,
		"shifted_positions": shifted_positions
	}
