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
	
	# Find the RoomLoader and restart current room
	var room_loader = get_tree().root.find_child("RoomManager", true, false)
	if room_loader and room_loader.has_method("restart_current_room"):
		call_deferred("_restart_room", room_loader)
	else:
		push_error("RoomLoader not found or doesn't have restart_current_room method!")

func _restart_room(room_loader: Node) -> void:
	room_loader.restart_current_room()
