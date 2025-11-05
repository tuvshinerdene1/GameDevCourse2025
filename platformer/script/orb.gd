extends Area2D
@export var pull_radius: float = 120.0
@export var snap_zone: float = 40.0
@export var bounce_force: float = 500.0
@export var launch_speed: float = 700.0
@export var upward_launch_bonus: float = 150.0
@export var charge: int = 1
@export var positive_orb_color: Color = Color(0, 0.8, 1, 1) # cyan
@export var negative_orb_color: Color = Color(0, 0.8, 1, 1) # cyan
@export var radius: float = 20.0
@export var glow: bool = true

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var player: CharacterBody2D = null
var is_player_inside: bool = false
var was_charge_flipped: bool = false

func _ready() -> void:
	set_circle_radius()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("get_charge"):
		player = body
		is_player_inside = true

func _on_body_exited(body: Node) -> void:
	if body == player:
		player = null
		is_player_inside = false
		was_charge_flipped = false
		
func _physics_process(delta: float) -> void:
	if not player or not is_player_inside:
		return
	var player_charge = player.get_charge()
	var to_player = player.global_position - global_position
	var dist = to_player.length()

	if player_charge != 0 and charge != 0 and charge != player_charge:
		if dist > snap_zone:
			var pull_dir = to_player.normalized()
			player.global_position += pull_dir * 300.0 * delta
		else:
			player.global_position = global_position
			_check_charge_flip()
	elif player_charge != 0 and charge == player_charge:
		var push_dir = to_player.normalized()
		player.velocity = push_dir * bounce_force
		
	
func _check_charge_flip():
	if not was_charge_flipped and Input.is_action_just_pressed("positive_current"):
		was_charge_flipped = true
		_launch_player()
	elif not was_charge_flipped and Input.is_action_just_pressed("negative_current"):
		was_charge_flipped = true
		_launch_player()

#func _check_charge_flip():
	#if not was_charge_flipped and charge != 0:
		#if charge == 1:
			#if Input.is_action_just_pressed("negative_current"):
				#was_charge_flipped = true
				#going_out_orb()
				#return
			#elif Input.is_action_just_pressed("positive_current"):
				#was_charge_flipped = true
				#_launch_player()
		#elif charge == -1:
			#if Input.is_action_just_pressed("positive_current"):
				#was_charge_flipped = true
				#going_out_orb()
				#return
			#elif Input.is_action_just_pressed("negative_current"):
				#was_charge_flipped = true
				#_launch_player()

func _launch_player():
	var input_dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	var launch_dir: Vector2

	if input_dir.length() > 0.1:
		launch_dir = input_dir.normalized()
	else:
		launch_dir = Vector2.UP
	
	if abs(input_dir.x) < 0.1:
		launch_dir.y = -1.0
		player.velocity = launch_dir * (launch_speed + upward_launch_bonus)
	else:
		player.velocity = launch_dir * launch_speed
	going_out_orb()

func going_out_orb():
	player = null
	is_player_inside = false
	await get_tree().create_timer(0.1).timeout
	was_charge_flipped = false

func _draw():
	var orb_color: Color
	if charge == 1:
		orb_color = positive_orb_color
	else:
		orb_color = negative_orb_color
	draw_circle(Vector2.ZERO, radius, orb_color)
	if glow:
		# Outer glow ring
		draw_circle(Vector2.ZERO, radius * 1.2, orb_color * Color(1, 1, 1, 0.3))
		draw_circle(Vector2.ZERO, radius * 1.4, orb_color * Color(1, 1, 1, 0.1))

func set_circle_radius():
	var circle = CircleShape2D.new()
	circle.radius = radius
	collision_shape.shape = circle
