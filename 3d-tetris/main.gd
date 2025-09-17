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
var block = preload('res://blocks/block.tscn')
var instance = null
var spawnPoint
var move_vector = Vector3(0,-1,0)
var grid_size = 10
var time_since_last_move: float = 0.0
var time_since_last_move_hor: float = 0.0
var move_interval: float = 0.0

var grid = {}
var grid_width = 10000
var grid_height = 10000
var grid_depth = 10000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_block()
	move_interval = 1/speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(instance != null):
		_move_horizontally(delta)
		_move(delta)

func _spawn_block():
	if instance != null:
		_clear()
	instance = shapes[randi()%shapes.size()].instantiate()
	spawnPoint = get_node("spawnPoint")
	add_child(instance)
	instance.global_position = spawnPoint.global_position
	instance.hit.connect(on_block_hit)
	time_since_last_move = 0.0
	time_since_last_move_hor = 0.0
	var spawn_positions = get_piece_grid_positions(instance)
	if is_any_grid_position_occupied(spawn_positions):
		print("Game Over: Spawn point blocked!")
		get_tree().reload_current_scene()  # Simple game over: restart scene

	
func on_block_hit():
	print("block has hit something")
	_stop_block()
	
func _stop_block():
	# Lock the shape in place by adding all its grid positions
	for grid_pos in get_piece_grid_positions(instance):
		grid[grid_pos] = true
	_spawn_block()

func _move(delta):
	time_since_last_move += delta
	var current_move_interval = move_interval
	if Input.is_action_pressed("boost"):
		current_move_interval /= boost_multiplier
	if time_since_last_move >= current_move_interval:
		var new_pos = instance.global_position + move_vector * grid_size
		if can_move_to(new_pos):
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
		if moved and can_move_to(new_pos):
			instance.global_position = new_pos
			time_since_last_move_hor = 0
		
func _clear():
	if instance != null:
		instance = null
	
	
#Helper functions for grid management
func snap_to_grid(pos:Vector3) ->Vector3:
	var grid_pos = grid_position(pos)
	return Vector3(grid_pos.x,grid_pos.y, grid_pos.z)*grid_size
	
func grid_position(pos:Vector3)->Vector3i:
	return Vector3i(round(pos.x/grid_size), round(pos.y/grid_size),round(pos.z/grid_size))
	
func get_piece_grid_positions(piece:Node3D) -> Array:
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
