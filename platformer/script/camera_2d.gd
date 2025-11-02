extends Camera2D

@export var bounds_node_path: NodePath

func _ready():
	# Make sure camera is enabled
	enabled = true
	
	if bounds_node_path:
		var bounds_node = get_node(bounds_node_path)
		var level_bounds: Rect2
		
		if bounds_node is ReferenceRect:
			level_bounds = Rect2(bounds_node.position, bounds_node.size)
		
		# Get the actual viewport size
		await get_tree().process_frame  # Wait one frame for viewport to be ready
		var viewport_size = get_viewport_rect().size
		
		var zoom_x = viewport_size.x / level_bounds.size.x
		var zoom_y = viewport_size.y / level_bounds.size.y
		
		var zoom_amount = min(zoom_x, zoom_y)
		zoom = Vector2(zoom_amount, zoom_amount)
		position = level_bounds.get_center()
