extends Node2D

signal item_picked_up

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_item_picked_up(item_node):
	item_picked_up.emit(item_node)
