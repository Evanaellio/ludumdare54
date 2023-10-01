extends Node

var selectedItem: Node2D = null
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
	if event is InputEventMouseButton && event.button_index == 4:
		if selectedItem != null:
			selectedItem.rotate(PI / 2)
			frameProcessed = true
	if event is InputEventMouseButton && event.button_index == 5:
		if selectedItem != null:
			selectedItem.rotate(-PI / 2)
			frameProcessed = true

func selectItem(item: Node2D):
	if (not frameProcessed) and selectedItem == null:
		print("selecting item")
		frameProcessed = true
		selectedItem = item
		selectedItem.disable_collisions()
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
