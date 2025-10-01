extends Node3D

var camera_angle = 0
@export var grid_width = 10
@export var grid_height = 25
@export var grid_depth = 10
@export var grid_size = 1

var camera: Camera3D

func _ready():
	camera = Camera3D.new()
	add_child(camera)
	_update_camera_position()

func _update_camera_position():
	var grid_center = Vector3(
		(grid_width * grid_size - grid_size) / 2.0,
		(grid_height * grid_size) / 2.0,
		(grid_depth * grid_size - grid_size) / 2.0
	)
	
	var camera_distance = max(grid_width, grid_depth) * 1.0
	var angle_rad = deg_to_rad(camera_angle)
	
	camera.global_position = Vector3(
		grid_center.x + sin(angle_rad) * camera_distance,
		grid_center.y,
		grid_center.z + cos(angle_rad) * camera_distance
	)
	
	camera.look_at(Vector3(grid_center.x, grid_center.y - camera_distance, grid_center.z), Vector3.UP)

func rotate_left():
	camera_angle -= 90
	if camera_angle < 0:
		camera_angle = 270
	_update_camera_position()

func rotate_right():
	camera_angle += 90
	if camera_angle >= 360:
		camera_angle = 0
	_update_camera_position()

func get_camera_angle() -> int:
	return camera_angle
