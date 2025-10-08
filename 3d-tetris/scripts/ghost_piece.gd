extends Node3D

var grid_management: GridManager
var target_piece: Node3D
var grid_size: float

func setup(grid_mgr: GridManager, piece: Node3D, size: float):
	grid_management = grid_mgr
	target_piece = piece
	grid_size = size

func update_position():
	if target_piece == null or not target_piece.is_inside_tree():
		return
		
	rotation = target_piece.rotation
	var ghost_pos = target_piece.global_position
	
	while grid_management.can_move_to(ghost_pos + Vector3(0, -1, 0) * grid_size):
		ghost_pos += Vector3(0, -1, 0) * grid_size
	
	global_position = ghost_pos

func apply_transparent_material(node: Node = null):
	if node == null:
		node = self
		
	if node is MeshInstance3D:
		var mat = node.get_active_material(0)
		var new_mat
		if mat and mat is StandardMaterial3D:
			new_mat = mat.duplicate()
		else:
			new_mat = StandardMaterial3D.new()
		new_mat.albedo_color = Color(1, 1, 1, 0.7)
		new_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		node.set_surface_override_material(0, new_mat)
	
	for child in node.get_children():
		apply_transparent_material(child)
