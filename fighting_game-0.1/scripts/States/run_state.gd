extends State
class_name WalkState

@export var animation_player: AnimationPlayer
@export var walk_animation_name: String
@export var sprite: AnimatedSprite2D
@export var move_speed: float = 200.0
@export var hitbox : Area2D
@export var parrybox: Area2D
@onready var character: CharacterBody2D = get_parent().get_parent()
@onready var player_num = get_parent().get_parent().get_player_num()
func Enter():
	super.Enter()
	if animation_player and animation_player.has_animation(walk_animation_name):
		animation_player.play(walk_animation_name)
	else:
		push_warning("Idle state: Animation player or idle animation not found")

func Update(delta: float):
	var move_dir = Input.get_action_strength("player_"+str(player_num)+"_move_right") - Input.get_action_strength("player_"+str(player_num)+"_move_left")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_roll"):
		Transitioned.emit(self,"roll")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_attack"):
		Transitioned.emit(self,"light_attack")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_stance_up"):
		Transitioned.emit(self,"up_idle_state")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_stance_down"):
		Transitioned.emit(self,"idle_state")
	if Input.is_action_just_pressed("player_"+str(player_num)+"_parry"):
		Transitioned.emit(self, "down_parry")
	if move_dir == 0:
		Transitioned.emit(self,"idle_state")
		return
	character.velocity.x = move_dir * move_speed
	character.move_and_slide()
	sprite.flip_h = move_dir < 0
	hitbox.scale.x = 1.0 if not sprite.flip_h else -1.0
	parrybox.scale.x = 1.0 if not sprite.flip_h else -1.0
	#if sign(move_dir) == sign(character.velocity.x):
		#hitbox.scale.x *= -1

func Exit():
	super.Exit()
