extends State
class_name  IdleState

@export var animation_player: AnimationPlayer
@export var idle_animation_name: String
@onready var player_num = get_parent().get_parent().get_player_num()
@onready var character = get_parent().get_parent()
func Enter():
	super.Enter()
	if animation_player and animation_player.has_animation(idle_animation_name):
		animation_player.play(idle_animation_name)
	else:
		push_warning("Idle state: Animation player or idle animation not found")

func Update(delta:float):
	if not character.is_on_floor():
		character.velocity += character.get_gravity()*delta
	var move_dir = Input.get_action_strength("player_"+str(player_num)+"_move_right") - Input.get_action_strength("player_"+str(player_num)+"_move_left")
	if move_dir != 0:
		Transitioned.emit(self, "walk_state")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_stance_up"):
		Transitioned.emit(self,"up_idle_state")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_roll"):
		Transitioned.emit(self,"roll")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_attack"):
		Transitioned.emit(self,"light_attack")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_parry"):
		Transitioned.emit(self,"down_parry")

func Exit():
	super.Exit()
