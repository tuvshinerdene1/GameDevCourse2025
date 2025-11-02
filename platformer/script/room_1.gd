extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var camera:  Camera2D = $Camera2D

func _ready() -> void:
	# ---- 1. Force root at origin (defensive) ----
	position = Vector2.ZERO

	# ---- 2. Compute pixel bounds of used tiles ----
	var map_rect: Rect2i = tilemap.get_used_rect()
	var tile_size: Vector2i = tilemap.tile_set.tile_size

	var world_rect := Rect2(
		map_rect.position * tile_size,
		map_rect.size * tile_size
	)

	# ---- 3. Apply camera limits ----
	camera.limit_left   = int(world_rect.position.x)
	camera.limit_top    = int(world_rect.position.y)
	camera.limit_right  = int(world_rect.end.x)
	camera.limit_bottom = int(world_rect.end.y)

	# ---- 4. Make this camera current (redundant but safe) ----
	camera.make_current()
