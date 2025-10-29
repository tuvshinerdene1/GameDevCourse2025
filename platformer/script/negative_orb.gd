extends Area2D
@export var pull_radius: float = 120.0
@export var snap_zone: float = 40.0
@export var bounce_force: float = 500.0
@export var launch_speed: float = 700.0
@export var upward_launch_bonus: float = 150.0
@export var charge := -1

var player: CharacterBody2D = null
var is_player_inside : bool = false
var was_charge_flipped :bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node):
	if body is CharacterBody2D:
		player = body
		is_player_inside = true
		print("entered")


func _on_body_exited(body: Node):
	if body is CharacterBody2D:
		player = null
		is_player_inside = false
		was_charge_flipped = false
		print("exited")
		
func _physics_process(delta: float) -> void:
	if not player or not is_player_inside:
		return
	var player_charge = player.get("charge")
	var orb_charge_sign = sign(charge)
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	
	if player_charge != 0 and orb_charge_sign != 0 and orb_charge_sign != player_charge:
		if dist > snap_zone:
			var pull_dir = to_player.normalized()
			player.global_position += pull_dir * 300.0 * delta
		else:
			player.global_position = global_position
			_check_charge_flip()
	elif player_charge != 0 and orb_charge_sign == player_charge:
		if dist < pull_radius * 0.7:
			var push_dir = to_player.normalized()
			player.velocity = push_dir*bounce_force
			#player.global_position += push_dir*20


#
#func _check_charge_flip() -> void:
	#if not was_charge_flipped and Input.is_action_just_pressed("positive_current"):
		#was_charge_flipped = true
		#_launch_player()
	#elif not was_charge_flipped and Input.is_action_just_pressed("negative_current"):
		#was_charge_flipped = true
		#_launch_player()
func _check_charge_flip():
	if not was_charge_flipped and charge == -1:
		if Input.is_action_just_pressed("positive_current"):
			return
		elif Input.is_action_just_pressed("negative_current"):
			was_charge_flipped = true
			_launch_player()
	elif not was_charge_flipped and charge == 1:
		if Input.is_action_just_pressed("negative_current"):
			return
		elif Input.is_action_just_pressed("positive_current"):
			was_charge_flipped = true
			_launch_player()

func _launch_player() -> void:
	var input_dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	var launch_dir: Vector2
	
	if input_dir.length() > 0.1:
		# 8-way directional launch
		launch_dir = input_dir.normalized()
	else:
		# Default: upward
		launch_dir = Vector2.UP
	
	# Add upward bonus if no horizontal input
	if abs(input_dir.x) < 0.1:
		launch_dir.y = -1.0
		player.velocity = launch_dir * (launch_speed + upward_launch_bonus)
	else:
		player.velocity = launch_dir * launch_speed
	player = null
	is_player_inside = false
	await get_tree().create_timer(0.1).timeout
	was_charge_flipped = false
