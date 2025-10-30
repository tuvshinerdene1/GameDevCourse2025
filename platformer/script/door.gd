# RoomExit.gd – attach to every exit Area2D
extends Area2D

@export var next_room: PackedScene # Drag the next level here
signal room_finished

func _ready() -> void:
    # Make sure the Area2D actually detects the player
    connect("body_entered", _on_body_entered)

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        room_finished.emit()