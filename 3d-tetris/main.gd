extends Node
@export var speed: float = 1
@export var move_interval_hor:float = 0.2
@export var boost_multiplier:float = 1.5
@export var rotate_interval: float = 0.2
var shapes = [
	preload("res://blocks/CubeShape.tscn"),
	preload("res://blocks/IShape.tscn"),
	preload("res://blocks/LShape.tscn"),
	preload("res://blocks/TShape.tscn"),
	preload("res://blocks/ZShape.tscn")
	#preload("res://blocks/block.tscn")
]
var shapesIndex = null
var grid_management = null
var instance = null
var ghost_instance= null
var spawnPoint
var move_vector = Vector3(0,-1,0)
var time_since_last_move: float = 0.0
var time_since_last_move_hor: float = 0.0
var time_since_last_rotate: float =0.0
var move_interval: float = 0.0
var grid = []
var grid_width = 10
var grid_height = 100
var grid_depth = 10
var grid_size = 1
var current_layer = 1;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_block()
	move_interval = 1/speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(instance != null):
		_move(delta)
		_move_horizontally(delta)
		_rotate(delta)
		_update_ghost_position()
		
func _initialize():
	grid_management = GridManager.new(grid_width, grid_height, grid_depth, grid_size, instance, grid)
	instance.global_position = spawnPoint.global_position
	instance.hit.connect(on_block_hit)
	time_since_last_move = 0.0
	time_since_last_move_hor = 0.0
	
func _game_over_handler():
	var spawn_positions = grid_management.get_piece_grid_positions(instance)
	if grid_management.is_any_grid_position_occupied(spawn_positions):
		print("Game Over: Spawn point blocked!")
		get_tree().reload_current_scene()  
	
func _spawn_block():
	if instance != null:
		_clear()
	shapesIndex = randi()%shapes.size()
	instance = shapes[shapesIndex].instantiate()
	spawnPoint = get_node("spawnPoint")
	add_child(instance)
	_create_ghost()
	_initialize()
	grid_management.row_complete_handler(current_layer)
	_game_over_handler()
	
func on_block_hit():
	print("block h as hit something")
	_stop_block()

func _stop_block():
	var grid_positions = grid_management.get_piece_grid_positions(instance)
	for grid_pos in grid_positions:
		if grid_pos.y >= 0 and not grid.has(grid_pos):
			grid.append(grid_pos)
	grid_management.row_complete_handler(current_layer)
	# Defer spawning to avoid race conditions
	call_deferred("_spawn_block")

func _move(delta):
	time_since_last_move += delta
	var current_move_interval = move_interval
	if Input.is_action_pressed("boost"):
		current_move_interval /= boost_multiplier
	if time_since_last_move >= current_move_interval:
		var new_pos = instance.global_position + move_vector * grid_size
		if grid_management.can_move_to(new_pos):
			instance.global_position = new_pos
			time_since_last_move = 0
		else:
			on_block_hit()
		
func _move_horizontally(delta):
	time_since_last_move_hor += delta
	if time_since_last_move_hor >= move_interval_hor:
		var moved = false
		var new_pos = instance.global_position
		if Input.is_action_pressed("move_down"):
			new_pos += Vector3(0, 0, 1) * grid_size
			moved = true
		elif Input.is_action_pressed("move_up"):
			new_pos += Vector3(0, 0, -1) * grid_size
			moved = true
		elif Input.is_action_pressed("move_right"):
			new_pos += Vector3(1, 0, 0) * grid_size
			moved = true
		elif Input.is_action_pressed("move_left"):
			new_pos += Vector3(-1, 0, 0) * grid_size
			moved = true
		
		if moved and grid_management.can_move_to(new_pos):
			instance.global_position = new_pos
			time_since_last_move_hor = 0
func _rotate(delta:float):
	time_since_last_rotate += delta
	if time_since_last_rotate >= rotate_interval:
		var rotated = false
		var new_rotation = instance.rotation_degrees
		if Input.is_action_just_pressed("rotate_left"):
			new_rotation.y += 90
			rotated = true
		elif Input.is_action_just_pressed("rotate_right"):
			new_rotation.y -= 90
			rotated = true
		if rotated and grid_management.can_rotate_to(instance, new_rotation):
			instance.rotation_degrees = new_rotation
			time_since_last_rotate = 0
			ghost_instance.rotation_degrees = new_rotation
			
		
	
			 
func _clear():
	if instance != null:
		#instance.queue_free()
		instance = null
func _create_ghost():
	if ghost_instance != null:
		#ghost_instance.queue_free()
		ghost_instance = null
		
	ghost_instance = shapes[shapesIndex].instantiate()
	add_child(ghost_instance)
	ghost_instance.rotation_degrees = instance.rotation_degrees
	
	# Recursively apply transparent material to all MeshInstance3D nodes
	_apply_transparent_material(ghost_instance)

func _apply_transparent_material(node: Node) -> void:
	if node is MeshInstance3D:
		var mat = node.get_active_material(0)
		var new_mat
		if mat and mat is StandardMaterial3D:
			new_mat = mat.duplicate()
		else:
			new_mat = StandardMaterial3D.new()
		new_mat.albedo_color = Color(1, 1, 1, 0.3)
		new_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		node.set_surface_override_material(0, new_mat)
	
	# Recurse through all children
	for child in node.get_children():
		_apply_transparent_material(child)
func _update_ghost_position():
	if instance == null or ghost_instance == null or not instance.is_inside_tree():
		return
	var ghost_pos = instance.global_position
	ghost_instance.rotation_degrees = instance.rotation_degrees
	while grid_management.can_move_to(ghost_pos + Vector3(0,-1,0)*grid_size):
		ghost_pos += Vector3(0,-1,0)*grid_size
	ghost_instance.global_position = grid_management.snap_to_grid(ghost_pos)
