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
func Update(delta:float):
	var move_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if move_dir != 0:
		Transitioned.emit(self, "walk_state")
	if Input.is_action_just_pressed("stance_up"):
		Transitioned.emit(self,"up_idle_state")
	if Input.is_action_just_pressed("roll"):
		Transitioned.emit(self,"roll")
	if Input.is_action_just_pressed("attack"):
		Transitioned.emit(self,"light_attack")
	if Input.is_action_just_pressed("parry"):
		Transitioned.emit(self,"down_parry")
func Exit():
	super.Exit()
