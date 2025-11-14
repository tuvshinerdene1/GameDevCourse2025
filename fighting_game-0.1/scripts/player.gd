extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var player_num = 1
@export var health = 3

func get_player_num():
	return player_num
