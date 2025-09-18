class_name BlockMovement extends Node

@export var speed: float = 1
@export var move_interval_hor: float = 0.2
@export var boost_multiplier: float = 1.5
var move_vector = Vector3(0, -1, 0)
var grid_size = 10
var time_since_last_move: float = 0.0
var time_since_last_move_hor: float = 0.0
var move_interval: float = 0.0
var instance = null
var grid_manager: GridManager = null

func _ready() -> void:
	grid_manager = get_parent().get_node("GridManager")
	instance = get_parent().instance
	move_interval = 1 / speed

func _process(delta: float) -> void:
	if instance != null:
		_move_horizontally(delta)
		_move(delta)

func _move(delta):
	time_since_last_move += delta
	var current_move_interval = move_interval
	if Input.is_action_pressed("boost"):
		current_move_interval /= boost_multiplier
	if time_since_last_move >= current_move_interval:
		var new_pos = instance.global_position + move_vector * grid_size
		if grid_manager.can_move_to(new_pos, instance):
			instance.global_position = new_pos
			time_since_last_move = 0
		else:
			get_parent().on_block_hit()

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
		if moved and grid_manager.can_move_to(new_pos, instance):
			instance.global_position = new_pos
			time_since_last_move_hor = 0
