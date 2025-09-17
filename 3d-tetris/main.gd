extends Node
@export var speed: float = 1
@export var move_interval_hor:float = 0.2
@export var boost_multiplier:float = 1.5
var block = preload('res://blocks/block.tscn')
var instance = null
var spawnPoint
var move_vector = Vector3(0,-1,0)
var grid_size = 5
var time_since_last_move: float = 0.0
var move_interval: float = 0.0
var time_since_last_move_hor: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_block()
	move_interval = 1/speed

func _spawn_block():
	instance = block.instantiate()
	spawnPoint = get_node("spawnPoint")
	add_child(instance)
	instance.global_position = spawnPoint.global_position
	instance.hit.connect(on_block_hit)
	time_since_last_move = 0.0
	time_since_last_move_hor = 0.0
	
func on_block_hit():
	print("block has hit something")
	_stop_block()
	
func _stop_block():
	_clear()
	_spawn_block()

func _move(delta):
	time_since_last_move += delta
	var current_move_interval = move_interval
	if Input.is_action_pressed("boost"):
		current_move_interval /= boost_multiplier
	if(time_since_last_move>=current_move_interval):
		instance.global_position += move_vector*grid_size
		time_since_last_move = 0
		
func _move_horizontally(delta):
	time_since_last_move_hor += delta
	if time_since_last_move_hor >= move_interval_hor:
		if Input.is_action_just_pressed("move_down"):
			instance.global_position +=  Vector3(0,0,1)*grid_size
		elif Input.is_action_just_pressed("move_up"):
			instance.global_position += Vector3(0,0,-1)*grid_size
		elif Input.is_action_just_pressed("move_right"):
			instance.global_position += Vector3(1,0,0)*grid_size
		elif Input.is_action_just_pressed("move_left"):
			instance.global_position += Vector3(-1,0,0)*grid_size
		
func _clear():
	if instance != null:
		instance = null
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(instance != null):
		_move_horizontally(delta)
		_move(delta)
