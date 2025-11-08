extends State
class_name  IdleState

@export var animation_player: AnimationPlayer
@export var idle_animation_name: String

func Enter():
	super.Enter()
	if animation_player and animation_player.has_animation(idle_animation_name):
		animation_player.play(idle_animation_name)
	else:
		push_warning("Idle state: Animation player or idle animation not found")
		
func Exit():
	super.Exit()
