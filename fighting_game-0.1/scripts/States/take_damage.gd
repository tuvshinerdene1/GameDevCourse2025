extends State
class_name TakeDamage

@export var animation_player: AnimationPlayer
@export var take_damage_animation_name: String
@onready var character = get_parent().get_parent() as CharacterBody2D
@onready var player_num = get_parent().get_parent().get_player_num()

var played_anim: String  # Track which anim finished

func Enter():
	super.Enter()
	character.current_health -= 1  # Damage first
	
	if animation_player and animation_player.has_animation(take_damage_animation_name):
		played_anim = take_damage_animation_name
		animation_player.play(played_anim)
		# Connect signal (one-shot, auto-disconnects after emit)
		animation_player.animation_finished.connect(_on_damage_anim_finished, CONNECT_ONE_SHOT)
	else:
		push_warning("TakeDamage: AnimationPlayer or '%s' not found!" % take_damage_animation_name)
		Transitioned.emit(self, "idle_state")  # Fallback immediate exit

func Update(delta: float):
	if Input.is_action_just_pressed("player_"+str(player_num)+"_roll"):
		Transitioned.emit(self,"roll")

func _on_damage_anim_finished(anim_name: String):
	if anim_name == played_anim:
		# Check health for death transition
		if character.current_health <= 0:
			Transitioned.emit(self, "death")
		else:
			Transitioned.emit(self, "idle_state")
