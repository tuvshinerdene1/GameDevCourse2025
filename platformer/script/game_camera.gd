extends Camera2D

# ------------------------------------------------------------------
# SETTINGS
# ------------------------------------------------------------------
@export var padding: Vector2 = Vector2(50, 50)   # extra space around room
@export var min_zoom: float = 0.2                # safety

# ------------------------------------------------------------------
# INTERNAL (these were missing!)
# ------------------------------------------------------------------
var target_zoom: Vector2 = Vector2.ONE
var zoom_speed: float = 5.0

func _ready() -> void:
	await get_tree().process_frame
	fit_to_room()

# ------------------------------------------------------------------
# PUBLIC – call after every room change
# ------------------------------------------------------------------
func fit_to_room() -> void:
	var room = _find_current_room()
	if not room:
		push_warning("GameCamera: No room found!")
		return
	
	var bounds = _get_room_bounds(room)
	if not bounds.has_area():
		push_warning("GameCamera: Could not calculate room bounds!")
		return

	# 1. Set limits so camera never leaves room
	limit_left   = int(bounds.position.x - padding.x)
	limit_top    = int(bounds.position.y - padding.y)
	limit_right  = int(bounds.end.x     + padding.x)
	limit_bottom = int(bounds.end.y     + padding.y)

	# 2. Zoom out to fit whole room in window
	var viewport = get_viewport().size
	var room_size = bounds.size + padding * 2
	
	var zoom_x = viewport.x / room_size.x
	var zoom_y = viewport.y / room_size.y
	var desired_zoom = min(zoom_x, zoom_y)
	desired_zoom = max(desired_zoom, min_zoom)
	
	target_zoom = Vector2(desired_zoom, desired_zoom)

	# 3. Center camera on room center
	global_position = bounds.get_center()

# ------------------------------------------------------------------
# Smooth zoom interpolation
# ------------------------------------------------------------------
func _process(delta: float) -> void:
	if zoom != target_zoom:
		zoom = zoom.lerp(target_zoom, zoom_speed * delta)

# ------------------------------------------------------------------
# Helper: find the current room node
# ------------------------------------------------------------------
func _find_current_room() -> Node:
	# Try RoomManager autoload first
	var rm = get_node_or_null("/root/RoomManager")
	if rm and rm.has_method("get_current_room"):
		return rm.get_current_room()
	
	# Fallback: walk up the tree
	var p = get_parent()
	while p:
		if p.get_parent() and p.get_parent().name == "RoomManager":
			return p
		p = p.get_parent()
	return null

# ------------------------------------------------------------------
# Bounds detection (RoomBounds → TileMap → CollisionShape2D)
# ------------------------------------------------------------------
func _get_room_bounds(room: Node) -> Rect2:
	var rect = Rect2()

	# 1. Explicit RoomBounds node (recommended)
	var bounds_node = room.find_child("RoomBounds", true, false)
	if bounds_node is Node2D:
		var size = bounds_node.get_meta("size", Vector2(1024, 600)) as Vector2
		return Rect2(bounds_node.global_position, size)

	# 2. TileMaps
	for tilemap in room.get_children():
		if tilemap is TileMap:
			var used = tilemap.get_used_rect()
			var cell_size = tilemap.tile_set.tile_size if tilemap.tile_set else Vector2(64, 64)
			var world_rect = Rect2(
				tilemap.global_position + used.position * cell_size,
				used.size * cell_size
			)
			rect = world_rect if rect == Rect2() else rect.merge(world_rect)

	# 3. CollisionShape2D fallback
	if rect == Rect2():
		for node in room.get_children():
			if node is CollisionShape2D and node.shape is RectangleShape2D:
				var shape = node.shape as RectangleShape2D
				var pos = node.global_position - shape.extents
				var size = shape.extents * 2
				var shape_rect = Rect2(pos, size)
				rect = shape_rect if rect == Rect2() else rect.merge(shape_rect)

	return rect
