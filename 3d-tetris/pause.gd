extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide the pause menu initially
	hide()
	# Ensure the game is not paused
	get_tree().paused = false
	# Set process mode to always so it works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect button signals
	var resume_button = get_node_or_null("ResumeButton")
	var exit_button = get_node_or_null("ExitButton")
	
	if resume_button and not resume_button.pressed.is_connected(on_resume_pressed):
		resume_button.pressed.connect(on_resume_pressed)
	if exit_button and not exit_button.pressed.is_connected(on_exit_pressed):
		exit_button.pressed.connect(on_exit_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Toggle pause menu when Escape/Pause key is pressed
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	# Toggle the paused state
	get_tree().paused = !get_tree().paused
	
	# Show/hide the pause menu based on pause state
	if get_tree().paused:
		show()
	else:
		hide()

func on_resume_pressed() -> void:
	# Unpause the game and hide the menu
	toggle_pause()

func on_exit_pressed() -> void:
	# Unpause before changing scenes
	get_tree().paused = false
	# Change to main menu scene
	get_tree().change_scene_to_file("res://main_menu.tscn")
