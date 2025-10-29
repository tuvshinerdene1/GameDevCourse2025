extends Area2D
@export var pull_radius: float = 120.0
@export var snap_zone: float = 40.0
@export var launch_speed: float = 700.0
@export var upward_launch_bonus: float = 150.0

var is_plae

var charge := -1

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node):
	if body is CharacterBody2D:
		print("entered")


func _on_body_exited(body: Node):
	if body is CharacterBody2D:
		print("exited")
