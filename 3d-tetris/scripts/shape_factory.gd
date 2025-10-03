class_name ShapeFactory extends Node

# ----------------------------------------------------------------------
# Piece definitions (local offsets for each block)
# ----------------------------------------------------------------------
var shapes = [
	[Vector3i(0,0,0), Vector3i(1,0,0), Vector3i(0,0,1), Vector3i(1,0,1)], # O (cube)
	[Vector3i(0,0,0), Vector3i(1,0,0), Vector3i(2,0,0)], # I
	[Vector3i(0,0,0), Vector3i(1,0,0), Vector3i(2,0,0), Vector3i(0,0,1)], # L
	[Vector3i(0,0,0), Vector3i(-1,0,0), Vector3i(1,0,0), Vector3i(0,0,1)],# T
	[Vector3i(0,0,0), Vector3i(-1,0,0), Vector3i(0,0,1)] # Z
]

# Reference to the cube scene
var cube_scene1 = preload("res://blocks/block1.tscn")
var cube_scene2 = preload("res://blocks/block2.tscn")
var cube_scene3 = preload("res://blocks/block3.tscn")
var cube_scene4 = preload("res://blocks/block4.tscn")
var cube_scene5 = preload("res://blocks/block5.tscn")

var cube_scenes = [cube_scene1,cube_scene2,cube_scene3,cube_scene4,cube_scene5]

# Optional: Colors for different piece types (if you want to tint them)
var base_colors = [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.YELLOW,
	Color.PURPLE
]

# ----------------------------------------------------------------------
# Validation
# ----------------------------------------------------------------------
func _ready():
	pass
# ----------------------------------------------------------------------
# Public API
# ----------------------------------------------------------------------
func create_random_piece(grid_size: float) -> Dictionary:
	var shape_index = randi() % shapes.size()
	return create_piece(shape_index, grid_size)

func create_piece(shape_index: int, grid_size: float) -> Dictionary:
	var piece = Node3D.new()
	
	# ------------------------------------------------------------------
	# Build each cube of the piece by instancing the scene
	# ------------------------------------------------------------------
	for offset in shapes[shape_index]:
		# Instance the cube scene
		var cube = cube_scenes[shape_index].instantiate()
		
		# Position it according to the shape offset
		cube.position = Vector3(offset.x, offset.y, offset.z) * grid_size
		
		# Optional: Apply color tint to differentiate pieces
		# (Only if you want to colorize pieces differently)
		# _apply_color_tint(cube, base_colors[shape_index])
		
		piece.add_child(cube)
	
	return { "piece": piece, "shape_index": shape_index }

# ----------------------------------------------------------------------
# Optional: Apply color tint to cube
# ----------------------------------------------------------------------
func _apply_color_tint(cube: Node3D, tint_color: Color):
	# Find MeshInstance3D in the cube scene
	var mesh_instance = _find_mesh_instance(cube)
	if mesh_instance and mesh_instance is MeshInstance3D:
		# Get or create material override
		var mat = mesh_instance.get_active_material(0)
		if mat:
			# Duplicate material to avoid affecting other instances
			mat = mat.duplicate()
			mat.albedo_color = tint_color
			mesh_instance.set_surface_override_material(0, mat)

func _find_mesh_instance(node: Node) -> Node:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = _find_mesh_instance(child)
		if result:
			return result
	return null
