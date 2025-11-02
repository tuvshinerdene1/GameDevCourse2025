extends Node

@export var start_room: PackedScene
@export var player_scene: PackedScene

var current_room: Node = null
var player: Node = null

func _ready() -> void:
	print("=== RoomManager debug ===")
	print("start_room assigned? ", start_room != null)
	if start_room:
		print("start_room path: ", start_room.resource_path)
	else:
		print("start_room is NULL")
	print("player_scene assigned? ", player_scene != null)
	print("==========================")

	if not start_room:
		push_error("start_room is not assigned!")
		return
	load_room(start_room)

func change_room(next_room_path: String, spawn_point_name: String = "Spawn") -> void:
	var next_packed = load(next_room_path) as PackedScene
	if not next_packed:
		push_error("Room not found: %s" % next_room_path)
		return
	call_deferred("load_room", next_packed, spawn_point_name)

func load_room(packed: PackedScene, spawn_point_name: String = "Spawn") -> void:
	if not packed:
		push_error("PackedScene is null!")
		return

	if current_room:
		current_room.queue_free()
		current_room = null

	current_room = packed.instantiate()
	if not current_room:
		push_error("Failed to instantiate: %s" % packed.resource_path)
		return

	add_child(current_room)

	if not player:
		if not player_scene:
			push_error("player_scene is not set!")
			return
		player = player_scene.instantiate()
		add_child(player)

	var spawn = find_spawn_point(current_room, spawn_point_name)
	if spawn:
		player.global_position = spawn.global_position
	else:
		push_warning("No spawn point '%s' in %s" % [spawn_point_name, packed.resource_path])

	connect_exits(current_room)

func find_spawn_point(room: Node, marker_name: String) -> Node2D:
	return room.find_child(marker_name, true, false) as Node2D

func connect_exits(room: Node) -> void:
	for node in room.get_children():
		if node is Area2D and node.has_meta("target_room"):
			if node.is_connected("body_entered", Callable(self, "_on_exit_entered")):
				node.disconnect("body_entered", Callable(self, "_on_exit_entered"))
			node.connect("body_entered", Callable(self, "_on_exit_entered").bind(node))

func _on_exit_entered(body: Node, exit_area: Area2D) -> void:
	if body != player:
		return

	var target_room: String = exit_area.get_meta("target_room") as String
	var spawn_point: String = exit_area.get_meta("spawn_point", "Spawn") as String

	call_deferred("change_room", target_room, spawn_point)
