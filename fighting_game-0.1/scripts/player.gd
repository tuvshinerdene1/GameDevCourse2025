extends CharacterBody2D
class_name  PlayerCharacter

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var player_num = 1
@export var health = 3
var current_health:int
var parry_source : Node2D
@onready var state_machine = $StateMachine
@onready var hurtbox: Area2D = $hurtbox
@onready var parrybox: Area2D = $parrybox

func _ready():
	current_health = health
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	parrybox.area_entered.connect(_on_parry_area_entered)
	
func _on_parry_area_entered(area: Area2D):
	if area.is_in_group("hitboxes"):
		var attacker = area.get_parent() as PlayerCharacter
		if attacker.player_num != player_num:
			attacker.get_parried(self)
			
func _on_hurtbox_area_entered(area: Area2D):
	if area.is_in_group("hitboxes"):
		var attacker = area.get_parent() as PlayerCharacter
		if attacker.player_num != player_num:
			take_damage()
			

		
func take_damage():
	state_machine.on_child_transitioned(state_machine.current_state, "take_damage")
	print('took damage')
	
func get_parried(parry_source):
	self.parry_source = parry_source
	state_machine.on_child_transitioned(state_machine.current_state, "get_parried")
	
func get_player_num():
	return player_num
