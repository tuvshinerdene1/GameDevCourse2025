# orb_visual.gd
extends Node2D

@export var orb_color: Color = Color(0, 0.8, 1, 1) # cyan
@export var radius: float = 20.0
@export var glow: bool = true

func _draw():
	draw_circle(Vector2.ZERO, radius, orb_color)
	if glow:
		# Outer glow ring
		draw_circle(Vector2.ZERO, radius * 1.4, orb_color * Color(1, 1, 1, 0.3))
		draw_circle(Vector2.ZERO, radius * 1.8, orb_color * Color(1, 1, 1, 0.1))
