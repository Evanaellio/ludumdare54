extends Node2D

@export var item: PackedScene:
	set(value):
		var instance = value.instantiate()
		add_child(instance)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
