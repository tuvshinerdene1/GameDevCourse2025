@tool
extends Node2D
@export var charge : int = 1
@onready var collision_shape = $CollisionShape2D
@onready var animation_player = $AnimatedSprite2D

var player_charge := 0

func _ready() -> void:
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("charge_changed"):
		player.charge_changed.connect(_on_charge_changed)
	update_collision()
	change_animation()

func _on_charge_changed(new_charge:int):
	player_charge = new_charge
	update_collision()
	
func _process(delta: float) -> void:
	if player_charge != charge:
		return

func update_collision():
	if collision_shape:
		collision_shape.disabled = (player_charge != charge)

func change_animation():
	if charge == 1:
		animation_player.play("negative")
	else:
		animation_player.play("positive")
