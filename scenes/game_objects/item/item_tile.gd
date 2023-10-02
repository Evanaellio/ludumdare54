extends Node2D

# The global item (bow, hatchet, etc) linked that this tile belongs to
@onready var item = $"../.."
@onready var img : Sprite2D = %TilePlaceholder

var clicking : bool = false
var frameProcessed = false;

func _ready():
	$TilePlaceholder.hide()
	item.tile_ready(self)

func _process(_delta):
	frameProcessed = false;

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if frameProcessed:
		return
	if event is InputEventMouseButton && event.button_index == 1:
		if event.pressed :
			clicking = true
			frameProcessed = true
		if !event.pressed && clicking:
			item.on_click()
			frameProcessed = true

func _on_area_2d_mouse_exited():
	clicking = false
