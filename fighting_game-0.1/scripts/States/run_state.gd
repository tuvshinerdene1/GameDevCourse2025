extends State
class_name WalkState

@export var animation_player: AnimationPlayer
@export var walk_animation_name: String
@export var sprite: AnimatedSprite2D

@export var move_speed: float = 200.0
@onready var character: CharacterBody2D = get_parent().get_parent()

func Enter():
	super.Enter()
	if animation_player and animation_player.has_animation(walk_animation_name):
		animation_player.play(walk_animation_name)
	else:
		push_warning("Idle state: Animation player or idle animation not found")

func Update(delta: float):
	var move_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if Input.is_action_just_pressed("roll"):
		Transitioned.emit(self,"roll")
	if Input.is_action_just_pressed("attack"):
		Transitioned.emit(self,"light_attack")
	if move_dir == 0:
		Transitioned.emit(self,"idle_state")
		return
	character.velocity.x = move_dir * move_speed
	character.move_and_slide()
	sprite.flip_h = move_dir < 0
func Exit():
	super.Exit()
