# spike.gd — attach to Area2D
extends Area2D

@export var player_group := "player"

# Track if we've already triggered death
var _dead := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _dead or not body.is_in_group(player_group):
		return
	
	_dead = true # Prevent double-trigger
	
	# Defer the scene reload to avoid physics callback issues
	get_tree().call_deferred("reload_current_scene")
	
	# Optionally queue_free the spike (deferred as well)
	call_deferred("queue_free")
