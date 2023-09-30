extends Node2D

# The global item (bow, hatchet, etc) linked that this tile belongs to
@onready var item = $"../.."
@onready var img : Sprite2D = %TilePlaceholder

var clicking : bool = false

func _ready():
	$TilePlaceholder.hide()
	item.tile_ready(self)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton && event.button_index == 1:
		if event.pressed :
			clicking = true
		if !event.pressed && clicking:
			item.on_click()

func _on_area_2d_mouse_exited():
	clicking = false
