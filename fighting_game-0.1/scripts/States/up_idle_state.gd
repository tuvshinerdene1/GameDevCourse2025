extends State
class_name  UpIdleState

@export var animation_player: AnimationPlayer
@export var up_idle_animation_name: String
@onready var player_num = get_parent().get_parent().get_player_num()

func Enter():
	super.Enter()
	if animation_player and animation_player.has_animation(up_idle_animation_name):
		animation_player.play(up_idle_animation_name)
	else:
		push_warning("Idle state: Animation player or idle animation not found")

func Update(delta:float):
	var move_dir = Input.get_action_strength("player_"+str(player_num)+"_move_right") - Input.get_action_strength("player_"+str(player_num)+"_move_left")
	if move_dir != 0:
		Transitioned.emit(self, "walk_state")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_stance_down"):
		Transitioned.emit(self,"idle_state")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_roll"):
		Transitioned.emit(self,"roll")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_attack"):
		Transitioned.emit(self, "heavy_attack")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_parry"):
		Transitioned.emit(self, "up_parry")
func Exit():
	super.Exit()
