class_name GridManager extends Node

var grid = {}
var grid_width = 10
var grid_height = 10
var grid_depth = 10
var grid_size = 10
var instance = null

func _init(grid_width, grid_height, grid_depth, grid_size, instance):
	self.grid_width = grid_width
	self.grid_height = grid_height
	self.grid_depth = grid_depth
	self.grid_size = grid_size
	self.instance = instance

func snap_to_grid(pos: Vector3) -> Vector3:
	var grid_pos = grid_position(pos)
	return Vector3(grid_pos.x, grid_pos.y, grid_pos.z) * grid_size

func grid_position(pos: Vector3) -> Vector3i:
	return Vector3i(round(pos.x / grid_size), round(pos.y / grid_size), round(pos.z / grid_size))

func get_piece_grid_positions(piece: Node3D) -> Array:
	var positions = []
	var piece_pos = grid_position(piece.global_position)
	for child in piece.get_children():
		if child is Node3D:
			var local_pos = grid_position(child.global_position - piece.global_position)
			positions.append(piece_pos + local_pos)
	return positions

func is_any_grid_position_occupied(grid_positions: Array) -> bool:
	for pos in grid_positions:
		if grid.has(pos):
			return true
	return false

func can_move_to(new_pos: Vector3) -> bool:
	var grid_positions = get_piece_grid_positions(instance)
	var offset = grid_position(new_pos) - grid_position(instance.global_position)
	for i in range(grid_positions.size()):
		var new_grid_pos = grid_positions[i] + offset
		if new_grid_pos.y < 0 or new_grid_pos.y >= grid_height or new_grid_pos.x < 0 or new_grid_pos.x >= grid_width or new_grid_pos.z < 0 or new_grid_pos.z >= grid_depth:
			return false
		if grid.has(new_grid_pos) and not grid_positions.has(new_grid_pos):
			return false
	return true
