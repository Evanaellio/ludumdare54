extends Node2D

# The global item (bow, hatchet, etc) linked that this tile belongs to
@onready var item = $"../.."

var clicking : bool = false

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton && event.pressed:
		clicking = true
	if event is InputEventMouseButton && !event.pressed && clicking:
		item.on_click()
		

func _on_area_2d_mouse_exited():
	clicking = false
