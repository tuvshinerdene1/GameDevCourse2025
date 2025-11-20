extends State
class_name Death

@export var animation_player: AnimationPlayer
@export var death_animation_name: String  # Fixed: "death_damage" → "death"
@onready var player_num = get_parent().get_parent().get_player_num()
@onready var character = get_parent().get_parent()

var played_anim: String  # Track which anim finished

func Enter():
	super.Enter()
	
	if animation_player and animation_player.has_animation(death_animation_name):
		played_anim = death_animation_name
		animation_player.play(played_anim)
		# Connect one-shot signal: auto-disconnects after first emit
		animation_player.animation_finished.connect(_on_death_anim_finished, CONNECT_ONE_SHOT)
	else:
		push_warning("Death: AnimationPlayer or '%s' not found!" % death_animation_name)
		_reload_scene()  # Fallback: immediate reload if no anim

func Exit():
	super.Exit()

func _on_death_anim_finished(anim_name: String):
	if anim_name == played_anim:
		_reload_scene()

func _reload_scene():
	get_tree().reload_current_scene()
