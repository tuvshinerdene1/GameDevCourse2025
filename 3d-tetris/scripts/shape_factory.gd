class_name ShapeFactory extends Node

var shapes = [
	[Vector3i(0,0,0), Vector3i(1,0,0), Vector3i(0,0,1), Vector3i(1,0,1)],  # Cube
	[Vector3i(0,0,0), Vector3i(1,0,0), Vector3i(2,0,0), Vector3i(3,0,0)],  # I
	[Vector3i(0,0,0), Vector3i(1,0,0), Vector3i(2,0,0), Vector3i(0,0,1)],  # L
	[Vector3i(0,0,0), Vector3i(-1,0,0), Vector3i(1,0,0), Vector3i(0,0,1)], # T
	[Vector3i(0,0,0), Vector3i(-1,0,0), Vector3i(1,0,1), Vector3i(0,0,1)]  # Z
]

var colors = [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.YELLOW,
	Color.PURPLE
]

func create_random_piece(grid_size: float) -> Dictionary:
	var shape_index = randi() % shapes.size()
	return create_piece(shape_index, grid_size)

func create_piece(shape_index: int, grid_size: float) -> Dictionary:
	var piece = Node3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(grid_size, grid_size, grid_size)
	var material = StandardMaterial3D.new()
	material.albedo_color = colors[shape_index]
	
	for offset in shapes[shape_index]:
		var cube = MeshInstance3D.new()
		cube.mesh = mesh
		cube.set_surface_override_material(0, material.duplicate())
		cube.position = Vector3(offset.x, offset.y, offset.z) * grid_size
		piece.add_child(cube)
	
	return {
		"piece": piece,
		"shape_index": shape_index
	}
