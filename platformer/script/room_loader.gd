# systems/RoomManager.gd
extends Node

## ------------------------------------------------------------------
## Public API
## ------------------------------------------------------------------
func start_level(first_room: PackedScene) -> void:
	load_room(first_room)

func go_to_next_room(next_room: PackedScene) -> void:
	load_room(next_room)

## ------------------------------------------------------------------
## Internal
## ------------------------------------------------------------------
var _current_room: Node2D = null

func load_room(packed: PackedScene) -> void:
	# Defer the whole operation – safe from physics callbacks
	call_deferred("_deferred_load_room", packed)

func _deferred_load_room(packed: PackedScene) -> void:
	# ------------------------------------------------------------------
	# 1. Remove the old room (if any)
	# ------------------------------------------------------------------
	if _current_room:
		# Detach immediately (still safe because we are outside physics)
		if is_inside_tree():
			remove_child(_current_room)
		_current_room.queue_free()
		# Wait one frame so any pending physics references are cleared
		await get_tree().process_frame

	# ------------------------------------------------------------------
	# 2. Instantiate the new room
	# ------------------------------------------------------------------
	var new_room: Node2D = packed.instantiate() as Node2D
	if not new_room:
		push_error("RoomManager: PackedScene did not instantiate a Node2D!")
		return

	_current_room = new_room
	add_child(_current_room)
	move_child(_current_room, 0) # optional: draw behind UI

	# ------------------------------------------------------------------
	# 3. Hook up every exit door
	# ------------------------------------------------------------------
	_connect_exits()

## ------------------------------------------------------------------
## Private helpers
## ------------------------------------------------------------------
func _connect_exits() -> void:
	for door in _current_room.find_children("*", "Area2D", true, false):
		if not door.has_signal("room_finished"):
			continue

		# Prevent duplicate connections
		if door.room_finished.is_connected(_on_door_room_finished):
			door.room_finished.disconnect(_on_door_room_finished)

		var next: PackedScene = door.get("next_room") as PackedScene
		if next:
			door.room_finished.connect(func():
				_on_door_room_finished(next)
			)
		else:
			push_warning("Door %s has no next_room assigned!" % door.name)

func _on_door_room_finished(next_room: PackedScene) -> void:
	load_room(next_room)
