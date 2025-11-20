extends State
class_name GetParried
@export var animation_player: AnimationPlayer
@export var take_damage_animation_name: String
@export var knockback_force: float = 800.0  # Tune this (pixels/sec)
@export var knockback_duration: float = 0.2  # How long knockback lasts
@onready var character = get_parent().get_parent() as CharacterBody2D
@onready var player_num = get_parent().get_parent().player_num
var played_anim: String
var knockback_direction: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

func Enter():
	super.Enter()
	
	# **NEW: Get knockback direction from parry source**
	var parry_source = get_parent().get_parent().parry_source  # Set this in parry_success()
	if parry_source:
		# Direction FROM attacker TO you (they get launched away)
		knockback_direction = (character.global_position - parry_source.global_position).normalized()
	else:
		# Fallback: Launch right (or use character facing)
		knockback_direction = Vector2.RIGHT * character.scale.x  # Respects flip_h
	
	# Apply initial velocity
	character.velocity = knockback_direction * knockback_force
	knockback_timer = knockback_duration
	
	# Play animation
	if animation_player and animation_player.has_animation(take_damage_animation_name):
		played_anim = take_damage_animation_name
		animation_player.play(played_anim)
		animation_player.animation_finished.connect(_on_damage_anim_finished, CONNECT_ONE_SHOT)

func Update(delta: float):
	# **NEW: Apply knockback during timer**
	if knockback_timer > 0:
		knockback_timer -= delta
		# Optional: Lerp velocity to 0 for smooth stop
		character.velocity = lerp(character.velocity, Vector2.ZERO, 10.0 * delta)
	else:
		# Stop knockback early if roll input
		character.velocity.x = 0
	
	# Roll interrupt (stops knockback)
	if Input.is_action_just_pressed("player_"+str(player_num)+"_roll"):
		Transitioned.emit(self, "roll")

func _on_damage_anim_finished(anim_name: String):
	if anim_name == played_anim:
		if character.current_health <= 0:
			Transitioned.emit(self, "death")
		else:
			Transitioned.emit(self, "idle_state")
