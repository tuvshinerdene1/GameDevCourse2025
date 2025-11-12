extends State
class_name HeavyAttackState


@export var animation_player: AnimationPlayer
@export var heavy_attack_animation: String
@export var sprite: AnimatedSprite2D

func Enter():
	super.Enter()
	if animation_player and animation_player.has_animation(heavy_attack_animation):
		animation_player.play(heavy_attack_animation)
	else:
		push_warning("Idle state: Animation player or idle animation not found")
		Transitioned.emit(self,"up_idle_state")
func Update(_delta: float):
	super.Update(_delta)
	if animation_player and not animation_player.is_playing():
		Transitioned.emit(self,"up_idle_state")
func Exit():
	super.Exit()
	if animation_player and animation_player.is_playing():
		animation_player.stop()
