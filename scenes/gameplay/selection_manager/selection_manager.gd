extends Node

var ItemsPacks = {
	"apple":     preload("res://scenes/game_objects/item_instances/apple.tscn"),
	"armor":     preload("res://scenes/game_objects/item_instances/armor.tscn"),
	"arrow":     preload("res://scenes/game_objects/item_instances/arrow.tscn"),
	"boomerang": preload("res://scenes/game_objects/item_instances/boomerang.tscn"),
	"bow":       preload("res://scenes/game_objects/item_instances/bow.tscn"),
	"hatchet":   preload("res://scenes/game_objects/item_instances/hatchet.tscn"),
	"key":       preload("res://scenes/game_objects/item_instances/key.tscn"),
	"magic_potion": preload("res://scenes/game_objects/item_instances/magic_potion.tscn"),
	"morning_jj":preload("res://scenes/game_objects/item_instances/morning_jj.tscn"),
	"potion":    preload("res://scenes/game_objects/item_instances/potion.tscn"),
	"sword":     preload("res://scenes/game_objects/item_instances/sword.tscn"),
}

var selectedItem: Node2D = null
var selectedItemSource: Node2D = null
var frameProcessed = false
var locked = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _process(delta):
	frameProcessed = false;
	if not selectedItem == null:

		snap_item_to_cursor()
		selectedItem.display_preview()

func _input(event: InputEvent):
	if frameProcessed:
		return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_A:
			if not selectedItem == null:
				selectedItem.custom_rotate(PI / 2)
				frameProcessed = true
	if event is InputEventMouseButton && selectedItem != null:
		if event.button_index == 4:
			selectedItem.custom_rotate(PI / 2)
			frameProcessed = true
		if event.button_index == 5:
			selectedItem.custom_rotate(-PI / 2)
			frameProcessed = true
		if event.button_index == 2 && not event.pressed && not selectedItemSource == null:
			selectedItemSource.unselectItem(selectedItem)


func selectItem(item: Node2D, source: Node2D, snapCursor: bool = false):
	if (not frameProcessed) and selectedItem == null and not locked:
		selectedItemSource = source
		selectedItem = item
		selectedItem.disable_collisions()
		selectedItem.z_index = 999
		item.clear_previously_occupied_by_me()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

		if snapCursor:
			snap_cursor_to_item()
		frameProcessed = true
		return true
	return false

func forceSelectItem(item: Node2D, source: Node2D):
	if not locked:
		selectedItem = null
		frameProcessed = false
		selectItem(item, source, true)


func dropItem(target):
	if (not frameProcessed) and not selectedItem == null:
		if target.canItemBePlaced(selectedItem):
			selectedItem.z_index = 10
			var newSelectedItem = target.placeItem(selectedItem)
			if newSelectedItem == null:
				selectedItem = null
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			frameProcessed = true

func destroyItem():
	if (not frameProcessed) and not selectedItem == null:
		print("destroy item")
		frameProcessed = true
		selectedItem.clear_preview()
		selectedItem.queue_free()
		selectedItem = null
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
func snap_item_to_cursor():
	if selectedItem == null:
		return
	var mousePosition = get_viewport().get_mouse_position()
	selectedItem.global_position = mousePosition

func snap_cursor_to_item():
	if selectedItem == null:
		return
	get_viewport().warp_mouse(selectedItem.global_position)
