extends Control

signal dialogue_started
signal dialogue_ended
signal choice_selected(choice_index: int, choice_data: Dictionary)

@onready var portrait_container = $MarginContainer/HBoxContainer/PortraitPanel
@onready var portrait_texture = $MarginContainer/HBoxContainer/PortraitPanel/Portrait
@onready var speaker_name = $MarginContainer/HBoxContainer/DialoguePanel/VBoxContainer/SpeakerName
@onready var dialogue_text = $MarginContainer/HBoxContainer/DialoguePanel/VBoxContainer/DialogueText
@onready var choices_container = $MarginContainer/HBoxContainer/DialoguePanel/VBoxContainer/ChoicesContainer

var current_dialogue_data: Dictionary = {}
var current_node_id: String = ""
var dialogue_tree: Dictionary = {}
var portraits: Dictionary = {}

var is_active: bool = false
var text_speed: float = 0.03
var current_text: String = ""
var displayed_text: String = ""
var text_timer: float = 0.0
var is_text_complete: bool = false

func _ready():
	hide()
	_setup_ui_style()
	# Allow this node to process even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if not is_active or is_text_complete:
		return
	
	text_timer += delta
	if text_timer >= text_speed:
		text_timer = 0.0
		_reveal_next_character()

func _input(event):
	if not is_active:
		return
	
	if event.is_action_pressed("ui_accept"):
		if not is_text_complete:
			_complete_text_immediately()
		else:
			_handle_continue()

func load_dialogue_tree(tree_data: Dictionary):
	dialogue_tree = tree_data

func load_portraits(portrait_data: Dictionary):
	portraits = portrait_data

func start_dialogue(node_id: String):
	if not dialogue_tree.has(node_id):
		push_error("Dialogue node not found: " + node_id)
		return
	
	current_node_id = node_id
	is_active = true
	show()
	emit_signal("dialogue_started")
	_display_node(node_id)
	
	# Pause the game
	get_tree().paused = true

func _display_node(node_id: String):
	var node = dialogue_tree[node_id]
	
	# Update portrait
	if portraits.has(node.get("speaker_id", "")):
		portrait_texture.texture = portraits[node["speaker_id"]]
		portrait_container.show()
	else:
		portrait_container.hide()
	
	# Update speaker name
	speaker_name.text = node.get("speaker", "")
	
	# Start text reveal
	current_text = node.get("text", "")
	displayed_text = ""
	is_text_complete = false
	text_timer = 0.0
	dialogue_text.text = ""
	
	# Clear previous choices
	for child in choices_container.get_children():
		child.queue_free()
	
	# If text is empty, show choices immediately
	if current_text == "":
		is_text_complete = true
		_show_choices(node)

func _reveal_next_character():
	if displayed_text.length() < current_text.length():
		displayed_text += current_text[displayed_text.length()]
		dialogue_text.text = displayed_text
	else:
		is_text_complete = true
		var node = dialogue_tree[current_node_id]
		_show_choices(node)

func _complete_text_immediately():
	displayed_text = current_text
	dialogue_text.text = displayed_text
	is_text_complete = true
	var node = dialogue_tree[current_node_id]
	_show_choices(node)

func _show_choices(node: Dictionary):
	var choices = node.get("choices", [])
	
	if choices.is_empty():
		# No choices means this is the end or auto-continue
		var next_node = node.get("next", "")
		if next_node != "":
			_create_continue_button()
		else:
			_create_end_button()
	else:
		for i in range(choices.size()):
			var choice = choices[i]
			_create_choice_button(choice, i)

func _create_choice_button(choice: Dictionary, index: int):
	var button = Button.new()
	button.text = choice.get("text", "...")
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 16)
	
	# Style the button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.15, 0.15, 0.2, 0.9)
	style_normal.border_width_left = 2
	style_normal.border_width_top = 2
	style_normal.border_width_right = 2
	style_normal.border_width_bottom = 2
	style_normal.border_color = Color(0.6, 0.6, 0.7, 0.5)
	style_normal.content_margin_left = 10
	style_normal.content_margin_top = 5
	style_normal.content_margin_right = 10
	style_normal.content_margin_bottom = 5
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.25, 0.25, 0.35, 0.95)
	style_hover.border_color = Color(0.8, 0.8, 0.9, 0.8)
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_hover)
	
	button.pressed.connect(func(): _on_choice_selected(choice, index))
	choices_container.add_child(button)

func _create_continue_button():
	var button = Button.new()
	button.text = "[Continue]"
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 14)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.25, 0.3, 0.8)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	
	var node = dialogue_tree[current_node_id]
	button.pressed.connect(func(): _display_node(node.get("next", "")))
	choices_container.add_child(button)

func _create_end_button():
	var button = Button.new()
	button.text = "[End Dialogue]"
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 14)
	
	button.pressed.connect(func(): end_dialogue())
	choices_container.add_child(button)

func _on_choice_selected(choice: Dictionary, index: int):
	emit_signal("choice_selected", index, choice)
	
	var next_node = choice.get("next", "")
	if next_node != "":
		_display_node(next_node)
	else:
		end_dialogue()

func _handle_continue():
	# This is only called when text is complete
	# If there's only one choice or a continue button, activate it
	if choices_container.get_child_count() == 1:
		var button = choices_container.get_child(0)
		if button is Button:
			button.pressed.emit()

func end_dialogue():
	is_active = false
	hide()
	emit_signal("dialogue_ended")
	get_tree().paused = false

func _setup_ui_style():
	# This sets up the base visual style
	# You can customize colors and appearance here
	pass
