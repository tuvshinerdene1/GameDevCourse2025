extends Node
var block = preload('res://blocks/block.tscn')
var instance = block.instantiate()
var spawnPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnPoint = get_node("spawnPoint")
	add_child(instance)
	instance.global_position = spawnPoint.global_position


func _clear():
	instance.queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
