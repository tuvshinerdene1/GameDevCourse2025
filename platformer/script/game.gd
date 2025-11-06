# Game.gd  (attached to the root node of your game, e.g. Node2D named "Game")
extends Node2D
@export var scorelabel : PackedScene
var points = 0

func add_point():
	points += 1
	scorelabel.text = "coins: "+str(points)
	

func _ready():
	# Set fullscreen mode
	print("in ready")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# Apply correct content scaling for 2D (Godot 4 syntax)
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	
	# Match viewport size to current window
	get_tree().root.size = DisplayServer.window_get_size()
