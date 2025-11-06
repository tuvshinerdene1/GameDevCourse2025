extends Node

@export var start_room: PackedScene
@export var player_scene: PackedScene
@export var transition_duration: float = 0.3  # Transition speed in seconds
@export var main_menu : PackedScene
var current_room: Node = null
var player: Node = null
var is_transitioning: bool = false

# Transition overlay (ColorRect for fade effect)
var transition_overlay: ColorRect
var canvas_layer: CanvasLayer
var current_room_scene: PackedScene = null  # Add this variable at the top
var current_spawn_point: String = "Spawn"   # Track current spawn point

func _ready() -> void:
	# Create canvas layer to keep overlay on top of camera
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # High layer to stay on top
	add_child(canvas_layer)
	
	# Create transition overlay
	transition_overlay = ColorRect.new()
	transition_overlay.color = Color.BLACK
	transition_overlay.size = get_viewport().get_visible_rect().size
	transition_overlay.position = Vector2(-transition_overlay.size.x, 0)  # Start off-screen
	canvas_layer.add_child(transition_overlay)
	
	if not start_room:
		push_error("start_room is not assigned!")
		return
	load_room(start_room)

func change_room(next_room_path: String, spawn_point_name: String = "Spawn") -> void:
	if is_transitioning:
		return  # Prevent multiple transitions at once
	
	var next_packed = load(next_room_path) as PackedScene
	if not next_packed:
		push_error("Room not found: %s" % next_room_path)
		return
	
	is_transitioning = true
	await fade_out()
	load_room(next_packed, spawn_point_name)
	await fade_in()
	is_transitioning = false

# Update load_room to store the current room scene
func load_room(packed: PackedScene, spawn_point_name: String = "Spawn") -> void:
	if not packed:
		push_error("PackedScene is null!")
		return
	
	# Store current room info for restarts
	current_room_scene = packed
	current_spawn_point = spawn_point_name
	
	if current_room:
		current_room.queue_free()
		current_room = null
	
	current_room = packed.instantiate()
	if not current_room:
		push_error("Failed to instantiate: %s" % packed.resource_path)
		return
	add_child(current_room)
	
	# Move room behind transition overlay
	move_child(current_room, 0)
	
	if not player:
		if not player_scene:
			push_error("player_scene is not set!")
			return
		player = player_scene.instantiate()
		add_child(player)
		move_child(player, 1)  # Player above room, below overlay
	
	var spawn = find_spawn_point(current_room, spawn_point_name)
	if spawn:
		player.global_position = spawn.global_position
	else:
		push_warning("No spawn point '%s' in %s" % [spawn_point_name, packed.resource_path])
	player.reset_charge()
	
	connect_exits(current_room)

# Add this new method to restart the current room
func restart_current_room() -> void:
	if is_transitioning:
		return
	
	if not current_room_scene:
		push_error("No current room to restart!")
		return
	
	is_transitioning = true
	await fade_out()
	load_room(current_room_scene, current_spawn_point)
	await fade_in()
	is_transitioning = false

func find_spawn_point(room: Node, marker_name: String) -> Node2D:
	return room.find_child(marker_name, true, false) as Node2D

func connect_exits(room: Node) -> void:
	for node in room.get_children():
		if node is Area2D and node.has_meta("target_room"):
			if node.is_connected("body_entered", Callable(self, "_on_exit_entered")):
				node.disconnect("body_entered", Callable(self, "_on_exit_entered"))
			node.connect("body_entered", Callable(self, "_on_exit_entered").bind(node))

func _on_exit_entered(body: Node, exit_area: Area2D) -> void:
	if body != player or is_transitioning:
		return
	
	var target_room: String = exit_area.get_meta("target_room") as String
	var spawn_point: String = exit_area.get_meta("spawn_point", "Spawn") as String
	
	# NEW: Check if this exit goes to main menu
	if target_room == "MAIN_MENU":  # Special keyword
		call_deferred("go_to_main_menu")
	else:
		call_deferred("change_room", target_room, spawn_point)
func get_current_room() -> Node:
	return current_room

# Transition effects
func fade_out() -> void:
	# Start overlay off-screen to the left
	var viewport_width = get_viewport().get_visible_rect().size.x
	transition_overlay.position.x = -viewport_width
	transition_overlay.modulate.a = 1.0
	
	# Slide in from left to cover screen
	var tween = create_tween()
	tween.tween_property(transition_overlay, "position:x", 0.0, transition_duration).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func fade_in() -> void:
	# Slide out to the right
	var viewport_width = get_viewport().get_visible_rect().size.x
	var tween = create_tween()
	tween.tween_property(transition_overlay, "position:x", viewport_width, transition_duration).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
func go_to_main_menu() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	await fade_out()
	
	# Clean up current room/player (optional but clean)
	if current_room:
		current_room.queue_free()
	if player:
		player.queue_free()
	
	# Switch to main menu
	get_tree().change_scene_to_packed(main_menu)
