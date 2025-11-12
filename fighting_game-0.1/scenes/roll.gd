extends State
class_name RollState


@export var animation_player: AnimationPlayer
@export var roll_attack_animation: String
@export var sprite: AnimatedSprite2D

@export var roll_speed: float = 300.0
@export var roll_distance:float = 120.0

@onready var character: CharacterBody2D = get_parent().get_parent()
var roll_direction:Vector2 = Vector2.RIGHT

func Enter():
	super.Enter()
	var anim_length = animation_player.get_animation(roll_attack_animation).length
	roll_speed = roll_distance/anim_length
	roll_direction = Vector2.RIGHT if not sprite.flip_h else Vector2.LEFT
	
	if animation_player and animation_player.has_animation(roll_attack_animation):
		animation_player.play(roll_attack_animation)
	else:
		push_warning("Idle state: Animation player or idle animation not found")
		Transitioned.emit(self,"idle_state")
		return

func Update(_delta: float):
	super.Update(_delta)
	if animation_player.is_playing():
		var move_dir = roll_direction*roll_speed
		character.velocity.x = move_dir.x
		character.move_and_slide()
		
	if animation_player and not animation_player.is_playing():
		Transitioned.emit(self,"idle_state")
func Exit():
	super.Exit()
	if animation_player and animation_player.is_playing():
		animation_player.stop()
