extends Node3D
signal hit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child.has_signal("hit"):
			child.hit.connect(_on_child_hit)

func _on_child_hit():
	hit.emit()
