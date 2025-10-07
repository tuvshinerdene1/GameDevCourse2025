# main.gd - Complete integration with Disco Elysium style dialogue
extends Node

@export var speed: float = 1
@export var boost_multiplier: float = 1.5

var grid_management: GridManager
var current_piece: Node3D
var ghost_piece: Node3D
var camera_controller: Node
var shape_factory: ShapeFactory
var dialogue_system: Control

var move_vector = Vector3(0, -1, 0)
var time_since_last_move: float = 0.0
var move_interval: float = 0.0

var grid = []
var grid_width = 5
var grid_height = 13
var grid_depth = 5
var grid_size = 1

var spawn_position: Vector3
var landed_blocks = {}
var game_over: bool = false

# Story tracking
var total_layers_cleared: int = 0
var consecutive_perfect_clears: int = 0
var near_death_saves: int = 0
var has_shown_intro: bool = false
var has_shown_first_clear: bool = false
var has_shown_near_death: bool = false
static var intro_already_shown: bool = false


func _ready() -> void:
	shape_factory = ShapeFactory.new()
	add_child(shape_factory)
	
	_setup_spawn_point()
	_setup_camera()
	_create_ground()
	_create_deadzone_layer()
	_setup_dialogue_system()
	
	move_interval = 1.0 / speed
	
	# Show intro dialogue before spawning first piece
	if not intro_already_shown:
		intro_already_shown = true
		has_shown_intro = true
		_show_intro_dialogue()
	else:
		_spawn_block()

func _setup_dialogue_system():
	# Load and setup dialogue system
	dialogue_system = preload("res://DialogueSystem.tscn").instantiate()
	add_child(dialogue_system)
	dialogue_system.dialogue_ended.connect(_on_dialogue_ended)
	dialogue_system.choice_selected.connect(_on_dialogue_choice_selected)
	
	# Load portraits (make sure these exist in your project)
	var portraits = {
		"narrator": preload("res://icon.svg"),  # Replace with actual portraits
		"voice_of_logic": preload("res://icon.svg"),
		# Add more portrait textures here
	}
	dialogue_system.load_portraits(portraits)

func _show_intro_dialogue():
	has_shown_intro = true
	var intro_tree = _create_intro_dialogue()
	dialogue_system.load_dialogue_tree(intro_tree)
	dialogue_system.start_dialogue("start")
	

func _create_intro_dialogue() -> Dictionary:
	return {
		"start": {
			"speaker": "THE VOID",
			"speaker_id": "narrator",
			"text": "You exist in a space between spaces. Geometric shapes fall from an invisible sky, obeying laws you don't remember learning.",
			"choices": [
				{"text": "[LOGIC] Analyze the environment", "next": "analyze"},
				{"text": "[INLAND EMPIRE] Feel the cosmic weight", "next": "cosmic"},
				{"text": "Accept your purpose", "next": "accept"}
			]
		},
		"analyze": {
			"speaker": "LOGIC",
			"speaker_id": "voice_of_logic",
			"text": "A 5×13×5 grid. Seven tetromino shapes. Rotation in three dimensions. The rules are clear: stack blocks, clear layers, survive.",
			"next": "end"
		},
		"cosmic": {
			"speaker": "INLAND EMPIRE",
			"speaker_id": "narrator",
			"text": "Each falling piece is a memory. Each cleared layer is a small death. The grid is your soul, and you must keep it from overflowing with chaos.",
			"next": "end"
		},
		"accept": {
			"speaker": "VOLITION",
			"speaker_id": "voice_of_logic",
			"text": "Good. No existential crisis today. Just blocks, gravity, and willpower. Let's begin.",
			"next": "end"
		},
		"end": {
			"speaker": "NARRATOR",
			"speaker_id": "narrator",
			"text": "The first piece materializes at the spawn point. Your eternal duty begins now.",
			"choices": []
		}
	}

func _on_dialogue_ended():
	# Resume game after dialogue
	if not game_over and current_piece == null:
		_spawn_block()

func _on_dialogue_choice_selected(choice_index: int, choice_data: Dictionary):
	# Track player choices for story branching
	print("Player selected choice: ", choice_index)
	print("Choice text: ", choice_data.get("text", ""))

func _process(delta: float) -> void:
	if game_over or dialogue_system.is_active:
		return
		
	if current_piece != null:
		_auto_fall(delta)
		current_piece.process_movement(delta)
		if ghost_piece != null:
			ghost_piece.update_position()
		camera_controller.camera_rotation()
		
		# Check for near-death situation
		_check_near_death()

func _check_near_death():
	if has_shown_near_death:
		return
		
	var highest_block = 0
	for pos in grid:
		if pos.y > highest_block:
			highest_block = pos.y
	
	# If stack reaches danger zone (2 blocks from top)
	if highest_block >= grid_height - 3:
		has_shown_near_death = true
		_show_near_death_dialogue()

func _show_near_death_dialogue():
	var tree = {
		"start": {
			"speaker": "PERCEPTION",
			"speaker_id": "narrator",
			"text": "The stack creeps toward the red zone. Death whispers from above.",
			"choices": [
				{"text": "[COMPOSURE - Challenging] Stay calm", "next": "calm"},
				{"text": "[HALF LIGHT] Panic!", "next": "panic"}
			]
		},
		"calm": {
			"speaker": "COMPOSURE",
			"speaker_id": "voice_of_logic",
			"text": "[COMPOSURE - Success] Your hands are steady. Your mind clear. You've been here before. You can recover.",
			"choices": []
		},
		"panic": {
			"speaker": "HALF LIGHT",
			"speaker_id": "narrator",
			"text": "TOO HIGH! TOO FAST! THE BLOCKS KEEP COMING! You're going to fail! Just like last time! JUST LIKE EVERY TIME!",
			"choices": []
		}
	}
	dialogue_system.load_dialogue_tree(tree)
	dialogue_system.start_dialogue("start")

func _setup_spawn_point():
	spawn_position = Vector3(
		(grid_width * grid_size - grid_size) / 2.0,
		(grid_height-2) * grid_size - grid_size,
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
	if game_over:
		return
	
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
	for pos in spawn_positions:
		if grid.has(pos):
			print("Game Over: Spawn point blocked at position ", pos)
			game_over = true
			call_deferred("_game_over")
			return
		if pos.y >= grid_height - 1:
			print("Game Over: Piece spawned in deadzone at height ", pos.y)
			game_over = true
			call_deferred("_game_over")
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
		current_piece.move_down(grid_size)
		time_since_last_move = 0.0
	elif Input.is_action_pressed("boost_left") or Input.is_action_pressed(("boost_right")):
		current_move_interval /= boost_multiplier
	
	if time_since_last_move >= current_move_interval:
		if current_piece.move_down(grid_size):
			time_since_last_move = 0

func _on_piece_landed():
	var grid_positions = grid_management.get_piece_grid_positions(current_piece)
	
	# Check for game over before adding to grid
	for grid_pos in grid_positions:
		if grid_pos.y >= grid_height - 1:
			print("Game Over: Block landed in deadzone at height ", grid_pos.y)
			current_piece.queue_free()
			if ghost_piece != null:
				ghost_piece.queue_free()
			game_over = true
			call_deferred("_game_over")
			return
	
	# Store the Node3D for each grid position
	for grid_pos in grid_positions:
		if grid_pos.y >= 0 and not grid.has(grid_pos):
			grid.append(grid_pos)
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

	current_piece.queue_free()

	# Clear completed layers and update blocks
	var clear_result = grid_management.row_complete_handler()
	if clear_result["cleared_layers"] > 0:
		print("Cleared ", clear_result["cleared_layers"], " layers!")
		total_layers_cleared += clear_result["cleared_layers"]
		consecutive_perfect_clears += 1
		
		# Show first clear dialogue
		if not has_shown_first_clear:
			has_shown_first_clear = true
			_show_first_clear_dialogue()
		
		var remove_set = {}
		for pos in clear_result["blocks_to_remove"]:
			remove_set[pos] = true
		
		var blocks_to_shift = []
		for shift in clear_result["shifted_positions"]:
			var old_pos = shift["old_pos"]
			var new_pos = shift["new_pos"]
			if landed_blocks.has(old_pos) and not remove_set.has(old_pos):
				blocks_to_shift.append({"old_pos": old_pos, "new_pos": new_pos, "block": landed_blocks[old_pos]})
		
		for pos in clear_result["blocks_to_remove"]:
			if landed_blocks.has(pos):
				var block = landed_blocks[pos]
				landed_blocks.erase(pos)
				block.queue_free()
		
		for shift_data in blocks_to_shift:
			var old_pos = shift_data["old_pos"]
			var new_pos = shift_data["new_pos"]
			var block = shift_data["block"]
			if landed_blocks.has(old_pos):
				landed_blocks.erase(old_pos)
			landed_blocks[new_pos] = block
			block.global_position = Vector3(
				new_pos.x * grid_size,
				new_pos.y * grid_size,
				new_pos.z * grid_size
			)
	else:
		consecutive_perfect_clears = 0
	
	grid = grid_management.grid
	if not game_over:
		call_deferred("_spawn_block")

func _show_first_clear_dialogue():
	var tree = {
		"start": {
			"speaker": "ACHIEVEMENT",
			"speaker_id": "voice_of_logic",
			"text": "*SUCCESS* - Your first complete layer vanishes. Cells aligned. Order restored from chaos.",
			"choices": [
				{"text": "Feel accomplished", "next": "accomplished"},
				{"text": "Demand more", "next": "more"}
			]
		},
		"accomplished": {
			"speaker": "EMPATHY",
			"speaker_id": "narrator",
			"text": "Those blocks... they served their purpose perfectly. Together, they created something complete. Then they let go.",
			"choices": []
		},
		"more": {
			"speaker": "ELECTROCHEMISTRY",
			"speaker_id": "narrator",
			"text": "YES! Do it AGAIN! Chase that feeling! Clear another layer! And another! FEED THE HUNGER FOR PERFECTION!",
			"choices": []
		}
	}
	dialogue_system.load_dialogue_tree(tree)
	dialogue_system.start_dialogue("start")

func _game_over():
	game_over = true
	print("=== GAME OVER ===")
	if current_piece != null:
		current_piece.queue_free()
		current_piece = null
	if ghost_piece != null:
		ghost_piece.queue_free()
		ghost_piece = null
	
	# Show game over dialogue
	var tree = {
		"start": {
			"speaker": "THE VOID",
			"speaker_id": "narrator",
			"text": "The tower collapses. Blocks scatter into nothing. The red zone claims another victim.",
			"choices": [
				{"text": "[VOLITION] Get up. Try again.", "next": "try_again"},
				{"text": "[LOGIC] Analyze what went wrong", "next": "analyze"},
				{"text": "[Give up]", "next": "give_up"}
			]
		},
		"try_again": {
			"speaker": "VOLITION",
			"speaker_id": "voice_of_logic",
			"text": "You cleared " + str(total_layers_cleared) + " layers. You can do better. The blocks still need you. They will always need you.",
			"choices": []
		},
		"analyze": {
			"speaker": "LOGIC",
			"speaker_id": "voice_of_logic",
			"text": "Gap management failed. Piece placement sub-optimal. But failure teaches. Next time, you'll see the patterns sooner.",
			"choices": []
		},
		"give_up": {
			"speaker": "INLAND EMPIRE",
			"speaker_id": "narrator",
			"text": "Perhaps the tower was meant to fall. Perhaps entropy always wins. But... will you let it?",
			"next": "try_again"
		}
	}
	dialogue_system.load_dialogue_tree(tree)
	dialogue_system.dialogue_ended.connect(_on_game_over_dialogue_ended, CONNECT_ONE_SHOT)
	dialogue_system.start_dialogue("start")

func _on_game_over_dialogue_ended():
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

func _reload_scene():
	_game_over()

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

func _create_deadzone_layer():
	var deadzone_height = grid_height - 1
	var deadzone_y = deadzone_height * grid_size
	
	var deadzone_container = Node3D.new()
	deadzone_container.name = "DeadzoneLayer"
	add_child(deadzone_container)
	
	var deadzone_material = StandardMaterial3D.new()
	deadzone_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	deadzone_material.albedo_color = Color(1.0, 0.2, 0.2, 0.02)
	deadzone_material.emission_enabled = true
	deadzone_material.emission = Color(1.0, 0.1, 0.1)
	deadzone_material.emission_energy_multiplier = 0.3
	
	var plane = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(grid_width * grid_size, grid_depth * grid_size)
	
	plane.mesh = plane_mesh
	plane.material_override = deadzone_material
	
	plane.position = Vector3(
		(grid_width * grid_size) / 2.0,
		deadzone_y,
		(grid_depth * grid_size) / 2.0
	)
	
	deadzone_container.add_child(plane)
