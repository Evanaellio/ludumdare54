extends Node2D

@export var item: PackedScene:
	set(value):
		item_pack = value
		if item_ptr != null:
			$Item.remove_child(item_ptr)
		if value != null:
			item_ptr = value.instantiate()
			$Item.add_child(item_ptr)
		else:
			item_ptr = null
	get:
		return item_pack

var rarity: int:
	set(value):
		item_ptr.get_node("Item").set_rarity(value)
	get:
		return item_ptr.get_node("Item").rarity

var item_pack = null
var item_ptr: Node2D = null
var placeholder_item: Node2D = null
var highlight: bool = false
var selected: bool = false

signal item_picked_up

func selectItem():
	if item_ptr != null and noItemSelected():
		selected = true
		$Sprite.modulate = "#bea5eb"
		item_ptr.get_node("Item").noise()
		item_picked_up.emit(self)

func item_placed_back():
	selected = false
	$Sprite.modulate = "#ffffff"

func item_dropped():
	selected = false
	$Sprite.modulate = "#ffffff"
	item = null
	item_ptr = null

func _on_area_2d_mouse_entered():
	if noItemSelected() and not selected:
		$Sprite.modulate = "#1edeff"

func _on_area_2d_mouse_exited():
	if not selected:
		$Sprite.modulate = "#ffffff"
		highlight = false

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton && event.button_index == 1:
		if event.pressed:
			highlight = true
		if !event.pressed && highlight :
			if item_ptr != null:
				selectItem()

func noItemSelected() -> bool:
	return get_node("/root/SelectionManager").selectedItem == null
