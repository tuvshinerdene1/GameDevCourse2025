extends Node

@export var speed: float = 1
@export var boost_multiplier: float = 1.5

var grid_management: GridManager
var current_piece: Node3D
var ghost_piece: Node3D
var camera_controller: Node
var shape_factory: ShapeFactory

var move_vector = Vector3(0, -1, 0)
var time_since_last_move: float = 0.0
var move_interval: float = 0.0

var grid = []
var grid_width = 7
var grid_height = 15
var grid_depth = 7
var grid_size = 1

var spawn_position: Vector3
var landed_blocks = {}  # Dictionary to map grid positions to Node3D objects

func _ready() -> void:
	shape_factory = ShapeFactory.new()
	add_child(shape_factory)
	
	_setup_spawn_point()
	_setup_camera()
	_create_ground()
	_spawn_block()
	
	move_interval = 1.0 / speed

func _process(delta: float) -> void:
	if current_piece != null:
		_auto_fall(delta)
		current_piece.process_movement(delta)
		ghost_piece.update_position()
		camera_controller.camera_rotation()

func _setup_spawn_point():
	spawn_position = Vector3(
		(grid_width * grid_size - grid_size) / 2.0,
		grid_height * grid_size - grid_size,
		(grid_depth * grid_size - grid_size) / 2.0
	)

func _setup_camera():
	camera_controller = preload("res://scripts/camera_controller.gd").new()
	camera_controller.grid_width = grid_width
	camera_controller.grid_height = grid_height
	camera_controller.grid_depth = grid_depth
	camera_controller.grid_size = grid_size
	add_child(camera_controller)

func _spawn_block():
	var piece_data = shape_factory.create_random_piece(grid_size)
	current_piece = piece_data["piece"]
	
	var piece_script = preload("res://scripts/piece_controller.gd")
	current_piece.set_script(piece_script)
	add_child(current_piece)
	
	grid_management = GridManager.new(grid_width, grid_height, grid_depth, grid_size, current_piece, grid)
	current_piece.setup(grid_management, camera_controller)
	current_piece.global_position = spawn_position
	current_piece.piece_landed.connect(_on_piece_landed)
	
	var spawn_positions = grid_management.get_piece_grid_positions(current_piece)
	if grid_management.is_any_grid_position_occupied(spawn_positions):
		print("Game Over: Spawn point blocked!")
		call_deferred("_reload_scene")
		return
	
	_create_ghost(piece_data["shape_index"])

func _create_ghost(shape_index: int):
	if ghost_piece != null:
		ghost_piece.queue_free()
	
	var ghost_data = shape_factory.create_piece(shape_index, grid_size)
	ghost_piece = ghost_data["piece"]
	
	var ghost_script = preload("res://scripts/ghost_piece.gd")
	ghost_piece.set_script(ghost_script)
	add_child(ghost_piece)
	
	ghost_piece.setup(grid_management, current_piece, grid_size)
	ghost_piece.apply_transparent_material()

func _auto_fall(delta: float):
	time_since_last_move += delta
	var current_move_interval = move_interval
	
	if Input.is_action_just_pressed("boost_left") and Input.is_action_pressed(("boost_right")):
		current_piece.global_position = ghost_piece.global_position
		
	elif Input.is_action_pressed("boost_left") or Input.is_action_pressed(("boost_right")):
		current_move_interval /= boost_multiplier
		

	if time_since_last_move >= current_move_interval:
		if current_piece.move_down(grid_size):
			time_since_last_move = 0

func _on_piece_landed():
	var grid_positions = grid_management.get_piece_grid_positions(current_piece)
	# Store the Node3D for each grid position
	for grid_pos in grid_positions:
		if grid_pos.y >= 0 and not grid.has(grid_pos):
			grid.append(grid_pos)
			# Store a reference to the block's Node3D (we'll clone the child nodes)
			for child in current_piece.get_children():
				if child is Node3D:
					var child_grid_pos = grid_management.grid_position(child.global_position)
					if child_grid_pos == grid_pos:
						var block_clone = child.duplicate()
						add_child(block_clone)
						landed_blocks[grid_pos] = block_clone
						block_clone.global_position = Vector3(
							grid_pos.x * grid_size,
							grid_pos.y * grid_size,
							grid_pos.z * grid_size
						)

	current_piece.queue_free()  # Add this line to remove the original piece

	# Clear completed layers and update blocks
	var clear_result = grid_management.row_complete_handler()
	if clear_result["cleared_layers"] > 0:
		print("Cleared ", clear_result["cleared_layers"], " layers!")
		
		# Create a set of positions that will be removed for quick lookup
		var remove_set = {}
		for pos in clear_result["blocks_to_remove"]:
			remove_set[pos] = true
		
		# First, collect blocks to shift (only blocks that aren't being removed)
		var blocks_to_shift = []
		for shift in clear_result["shifted_positions"]:
			var old_pos = shift["old_pos"]
			var new_pos = shift["new_pos"]
			# Make sure this block exists and isn't in the removal list
			if landed_blocks.has(old_pos) and not remove_set.has(old_pos):
				blocks_to_shift.append({"old_pos": old_pos, "new_pos": new_pos, "block": landed_blocks[old_pos]})
		
		# Remove blocks in cleared layers
		for pos in clear_result["blocks_to_remove"]:
			if landed_blocks.has(pos):
				var block = landed_blocks[pos]
				landed_blocks.erase(pos)
				block.queue_free()
		
		# Update the shifted blocks
		for shift_data in blocks_to_shift:
			var old_pos = shift_data["old_pos"]
			var new_pos = shift_data["new_pos"]
			var block = shift_data["block"]
			
			# Remove from old position in dictionary
			if landed_blocks.has(old_pos):
				landed_blocks.erase(old_pos)
			
			# Add to new position
			landed_blocks[new_pos] = block
			block.global_position = Vector3(
				new_pos.x * grid_size,
				new_pos.y * grid_size,
				new_pos.z * grid_size
			)
	
	grid = grid_management.grid  # Update the main grid
	call_deferred("_spawn_block")
func _reload_scene():
	get_tree().reload_current_scene()

func _create_ground():
	var ground = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	
	var border_size: float = 2.0
	
	plane_mesh.size = Vector2(
		grid_width * grid_size + border_size,
		grid_depth * grid_size + border_size
	)
	
	var material = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = """
		shader_type spatial;
		render_mode cull_disabled, unshaded;
		
		uniform float grid_width = 7.0;
		uniform float grid_depth = 7.0;
		uniform float grid_size = 1.0;
		uniform float border_size = 2.0;
		uniform vec3 grid_color = vec3(0.8, 0.8, 0.8);
		uniform vec3 background_color = vec3(0.2, 0.2, 0.2);
		uniform float line_thickness = 0.05;
		
		void fragment() {
			vec2 total_size = vec2(grid_width + border_size, grid_depth + border_size);
			vec2 uv = UV * total_size / grid_size;
			uv -= vec2(border_size / (2.0 * grid_size));
			bool in_grid = uv.x >= 0.0 && uv.x <= grid_width && uv.y >= 0.0 && uv.y <= grid_depth;
			vec3 color = background_color;
			if (in_grid) {
				vec2 grid = fract(uv);
				float line_x = step(grid.x, line_thickness) + step(1.0 - grid.x, line_thickness);
				float line_z = step(grid.y, line_thickness) + step(1.0 - grid.y, line_thickness);
				float line = min(line_x + line_z, 1.0);
				color = mix(grid_color, background_color, 1.0 - line);
			}
			ALBEDO = color;
		}
	"""
	material.shader = shader
	material.set_shader_parameter("grid_width", grid_width)
	material.set_shader_parameter("grid_depth", grid_depth)
	material.set_shader_parameter("grid_size", grid_size)
	material.set_shader_parameter("border_size", border_size)
	material.set_shader_parameter("grid_color", Vector3(0.8, 0.8, 0.8))
	material.set_shader_parameter("background_color", Vector3(0.2, 0.2, 0.2))
	material.set_shader_parameter("line_thickness", 0.05)
	
	ground.mesh = plane_mesh
	ground.set_surface_override_material(0, material)
	
	ground.position = Vector3(
		(grid_width * grid_size - grid_size) / 2.0,
		-grid_size/2,
		(grid_depth * grid_size - grid_size) / 2.0
	)
	
	add_child(ground)
