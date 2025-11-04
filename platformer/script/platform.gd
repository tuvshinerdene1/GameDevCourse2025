@tool
extends Node2D

# ─────────────────────────────────────────────────────────────────────────────
# Inspector-exported variables
# ─────────────────────────────────────────────────────────────────────────────
@export var direction : Vector2 = Vector2.RIGHT
@export var distance  : float   = 200.0
@export var speed     : float   = 100.0
@export var charge    : int     = 1          # 1 = positive, -1 = negative, 0 = neutral

# ─────────────────────────────────────────────────────────────────────────────
# Node references
# ─────────────────────────────────────────────────────────────────────────────
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape : CollisionShape2D = $CollisionShape2D


# ─────────────────────────────────────────────────────────────────────────────
# Internal state
# ─────────────────────────────────────────────────────────────────────────────
var _start_pos : Vector2
var _end_pos   : Vector2
var _t         : float = 0.0
var _dir       : int   = 1          # +1 forward, -1 backward

var player_charge : int = 0
var player_on_platform : bool = false   # <-- NEW: is player touching us?

func _ready() -> void:
	_start_pos = global_position
	_end_pos   = _start_pos + direction.normalized() * distance

	# Connect to player signal (safe, works even if player loads later)
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_signal("charge_changed"):
		player.charge_changed.connect(_on_player_charge_changed)

	# Initial animation & collision state
	_update_animation()


func _on_player_charge_changed(new_charge: int) -> void:
	player_charge = new_charge
	_update_animation()

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		player_on_platform = true
		  # may enable movement now

func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		player_on_platform = false



func _process(delta: float) -> void:
	if  player_charge != charge:
		return

	_t += delta * speed / distance * _dir

	if _t >= 1.0:
		_t = 1.0
		_dir = -1
	elif _t <= 0.0:
		_t = 0.0
		_dir = +1

	global_position = _start_pos.lerp(_end_pos, _t)

# ─────────────────────────────────────────────────────────────────────────────
# Update animation based on platform charge
# ─────────────────────────────────────────────────────────────────────────────
func _update_animation() -> void:
	if not animated_sprite: return
	if charge == 1:
		animated_sprite.play("positive")
	elif charge == -1:
		animated_sprite.play("negative")
	else:
		animated_sprite.play("neutral")   # optional
