extends State
class_name DownParryState


@export var animation_player: AnimationPlayer
@export var down_parry_animation: String
@export var sprite: AnimatedSprite2D

func Enter():
	super.Enter()
	if animation_player and animation_player.has_animation(down_parry_animation):
		animation_player.play(down_parry_animation)
	else:
		push_warning("Idle state: Animation player or idle animation not found")
		Transitioned.emit(self,"idle_state")
func Update(_delta: float):
	super.Update(_delta)
	if animation_player and not animation_player.is_playing():
		Transitioned.emit(self,"idle_state")
func Exit():
	super.Exit()
	if animation_player and animation_player.is_playing():
		animation_player.stop()
