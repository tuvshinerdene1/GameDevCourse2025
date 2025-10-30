extends Area2D
@export var pull_radius: float = 120.0
@export var snap_zone: float = 40.0
@export var bounce_force: float = 500.0
@export var launch_speed: float = 700.0
@export var upward_launch_bonus: float = 150.0

var player: CharacterBody2D = null
var is_player_inside: bool = false
var was_charge_flipped: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	pass
func _on_body_exited(body: Node) -> void:
	pass
func _physics_process(delta: float) -> void:
	pass

func _check_charge_flip():
	pass

func _launch_player():
	pass
