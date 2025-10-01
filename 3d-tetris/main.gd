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
	
	#if Input.is_action_just_pressed("camera_rotate_left"):
		#camera_controller.rotate_left()
	#elif Input.is_action_just_pressed("camera_rotate_right"):
		#camera_controller.rotate_right()

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
	## Only remove previous falling piece, not landed ones
	#if current_piece != null and not current_piece.landed:
		#current_piece.queue_free()
	
	var piece_data = shape_factory.create_random_piece(grid_size)
	current_piece = piece_data["piece"]
	
	var piece_script = preload("res://scripts/piece_controller.gd")
	current_piece.set_script(piece_script)
	add_child(current_piece)
	
	grid_management = GridManager.new(grid_width, grid_height, grid_depth, grid_size, current_piece, grid)
	current_piece.setup(grid_management, camera_controller)
	current_piece.global_position = spawn_position
	current_piece.piece_landed.connect(_on_piece_landed)
	
	# Check game over AFTER piece is positioned
	var spawn_positions = grid_management.get_piece_grid_positions(current_piece)
	if grid_management.is_any_grid_position_occupied(spawn_positions):
		print("Game Over: Spawn point blocked!")
		call_deferred("_reload_scene")
		return  # Don't create ghost if game over
	
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
	for grid_pos in grid_positions:
		if grid_pos.y >= 0 and not grid.has(grid_pos):
			grid.append(grid_pos)
	
	grid_management.row_complete_handler(1)
	call_deferred("_spawn_block")

func _game_over_handler():
	var spawn_positions = grid_management.get_piece_grid_positions(current_piece)
	if grid_management.is_any_grid_position_occupied(spawn_positions):
		print("Game Over: Spawn point blocked!")
		call_deferred("_reload_scene")

func _reload_scene():
	get_tree().reload_current_scene()

func _create_ground():
	var ground = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	
	# The size of the ground will be the grid size + a small, fixed border (e.g., 2 units)
	var border_size: float = 2.0
	
	plane_mesh.size = Vector2(
		grid_width * grid_size + border_size,
		grid_depth * grid_size + border_size
	)
	
	# --- Create Grid Material ---
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.2, 0.2)
	
	# Enable UV1 for custom texture scaling
	material.uv1_scale = Vector3(
		grid_width + border_size / grid_size, # Scale to cover the width
		grid_depth + border_size / grid_size, # Scale to cover the depth
		1.0
	)
	
	# You'll need to create a simple, repeating grid texture (a grid pattern on a transparent background)
	# For simplicity, we can use a texture built into Godot's visual shader or an external one.
	# The best method is usually a ShaderMaterial for a perfect procedural grid, 
	# but for a quick setup, let's use a simple texture with a hint of grid.
	# A placeholder for your grid texture:
	# material.albedo_texture = preload("res://path/to/your/grid_texture.png")
	# material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST # For sharp lines
	
	# A quick alternative is to just use a lighter color to differentiate the ground
	# If you want a proper grid pattern, you should use a **ShaderMaterial**.
	
	ground.mesh = plane_mesh
	ground.set_surface_override_material(0, material)
	
	# Position remains the same to center the plane
	ground.position = Vector3(
		(grid_width * grid_size - grid_size) / 2.0,
		-grid_size,
		(grid_depth * grid_size - grid_size) / 2.0
	)
	
	add_child(ground)
	
	
	#var material = StandardMaterial3D.new()
	#material.albedo_color = Color(0.2, 0.2, 0.2)
	#ground.mesh = plane_mesh
	#ground.set_surface_override_material(0, material)
	#
	## The position calculation remains the same because the plane mesh is centered
	## around its position. The existing calculation correctly centers the grid area.
	#ground.position = Vector3(
		#(grid_width * grid_size - grid_size) / 2.0,
		#0,
		#(grid_depth * grid_size - grid_size) / 2.0
	#)
	## --- MODIFICATIONS END HERE ---
	#
	#add_child(ground)
