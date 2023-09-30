extends Node2D

@export var item: PackedScene:
	set(value):
		item_pack = value
		if item_ptr != null:
			remove_child(item_ptr)
		if value != null:
			item_ptr = value.instantiate()
			add_child(item_ptr)
	get:
		return item_pack

var item_pack = null
var item_ptr: Node2D = null
var highlight: bool = false

signal item_picked_up

func selectItem():
	print("item picked up")
	item_picked_up.emit(item_ptr)
	item = null

func _on_area_2d_mouse_entered():
	$Sprite.modulate = "#1edeff"

func _on_area_2d_mouse_exited():
	$Sprite.modulate = "#ffffff"
	highlight = false

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton && event.pressed:
		highlight = true
	if event is InputEventMouseButton && !event.pressed && highlight:
		if item_ptr != null:
			selectItem()
