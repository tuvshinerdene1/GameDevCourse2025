extends Node
@export var speed: float = 1
@export var move_interval_hor:float = 0.2
@export var boost_multiplier:float = 1.5
var shapes = [
	preload("res://blocks/CubeShape.tscn"),
	preload("res://blocks/IShape.tscn"),
	preload("res://blocks/LShape.tscn"),
	preload("res://blocks/TShape.tscn"),
	preload("res://blocks/ZShape.tscn")
]
var grid_management = null
var instance = null
var spawnPoint
var move_vector = Vector3(0,-1,0)
var time_since_last_move: float = 0.0
var time_since_last_move_hor: float = 0.0
var move_interval: float = 0.0
var grid = {}
var grid_width = 20
var grid_height = 20
var grid_depth = 20
var grid_size = 10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_block()
	move_interval = 1/speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(instance != null):
		_move_horizontally(delta)
		_move(delta)
		
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
		get_tree().reload_current_scene()  # Simple game over: restart scene
	
func _spawn_block():
	if instance != null:
		_clear()
	instance = shapes[randi()%shapes.size()].instantiate()
	spawnPoint = get_node("spawnPoint")
	add_child(instance)
	_initialize()
	_game_over_handler()
	
func on_block_hit():
	print("block h as hit something")
	_stop_block()
	
func _stop_block():
	# Lock the shape in place by adding all its grid positions
	for grid_pos in grid_management.get_piece_grid_positions(instance):
		grid[grid_pos] = true
	print (grid)
	_spawn_block()
	grid_management.row_complete_handler()

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
		if Input.is_action_just_pressed("move_down"):
			new_pos += Vector3(0, 0, 1) * grid_size
			moved = true
		elif Input.is_action_just_pressed("move_up"):
			new_pos += Vector3(0, 0, -1) * grid_size
			moved = true
		elif Input.is_action_just_pressed("move_right"):
			new_pos += Vector3(1, 0, 0) * grid_size
			moved = true
		elif Input.is_action_just_pressed("move_left"):
			new_pos += Vector3(-1, 0, 0) * grid_size
			moved = true
		if moved and grid_management.can_move_to(new_pos):
		#if grid_management.can_move_to(new_pos):
			instance.global_position = new_pos
			time_since_last_move_hor = 0
		
func _clear():
	if instance != null:
		instance = null
