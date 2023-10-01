extends Node

var ItemsPacks = {
	"apple":     preload("res://scenes/game_objects/item_instances/apple.tscn"),
	"armor":     preload("res://scenes/game_objects/item_instances/armor.tscn"),
	"arrow":     preload("res://scenes/game_objects/item_instances/arrow.tscn"),
	"boomerang": preload("res://scenes/game_objects/item_instances/boomerang.tscn"),
	"bow":       preload("res://scenes/game_objects/item_instances/bow.tscn"),
	"hatchet":   preload("res://scenes/game_objects/item_instances/hatchet.tscn"),
	"key":       preload("res://scenes/game_objects/item_instances/key.tscn"),
	"morning_jj":preload("res://scenes/game_objects/item_instances/morning_jj.tscn"),
	"potion":    preload("res://scenes/game_objects/item_instances/potion.tscn"),
	"sword":     preload("res://scenes/game_objects/item_instances/sword.tscn"),
}

var selectedItem: Node2D = null
var selectedItemSource: Node2D = null
var frameProcessed = false;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _process(delta):
	frameProcessed = false;
	if selectedItem:
		snap_item_to_cursor()
		selectedItem.display_preview()

func _input(event: InputEvent):
	if frameProcessed:
		return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_A:
			if not selectedItem == null:
				selectedItem.rotate(PI / 2)
				frameProcessed = true
	if event is InputEventMouseButton && selectedItem != null:
		if event.button_index == 4:
			selectedItem.rotate(PI / 2)
			frameProcessed = true
		if event.button_index == 5:
			selectedItem.rotate(-PI / 2)
			frameProcessed = true
		if event.button_index == 2 && not event.pressed && not selectedItemSource == null:
			selectedItemSource.unselectItem(selectedItem)

func selectItem(item: Node2D, source: Node2D):
	if (not frameProcessed) and selectedItem == null:
		print("selecting item")
		frameProcessed = true
		selectedItemSource = source
		selectedItem = item
		selectedItem.disable_collisions()
		selectedItem.z_index = 999
		snap_item_to_cursor()
		item.clear_previously_occupied_by_me()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		

func dropItem(target):
	if (not frameProcessed) and not selectedItem == null:
		print("droping item")
		# La on demande à l'autre tanche de faire sa vérif - si oui, on balance
		# Bon ça va laisser l'item là comme une merde, mais bon
		frameProcessed = true
		if target.placeItem(selectedItem):
			selectedItem.z_index = 10
			selectedItem = null
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func destroyItem():
	if (not frameProcessed) and not selectedItem == null:
		print("destroy item")
		frameProcessed = true
		selectedItem.clear_preview()
		selectedItem.queue_free()
		selectedItem = null
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func snap_item_to_cursor():
	var mousePosition = get_viewport().get_mouse_position()
	selectedItem.global_position = mousePosition
