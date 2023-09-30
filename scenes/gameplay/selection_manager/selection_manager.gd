extends Node

var selectedItem: Node2D = null
var frameProcessed = false;

func _process(delta):
	frameProcessed = false;
	if selectedItem == null:
		pass
	else:
		snapItemToCursor()
		displayPreview()

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_A:
			if not selectedItem == null:
				selectedItem.rotate(PI / 2)

func selectItem(item: Node2D):
	if (not frameProcessed) and selectedItem == null:
		print("selecting item")
		frameProcessed = true
		selectedItem = item
		snapItemToCursor()

func dropItem(target):
	if (not frameProcessed) and not selectedItem == null:
		print("droping item")
		# La on demande à l'autre tanche de faire sa vérif - si oui, on balance
		# Bon ça va laisser l'item là comme une merde, mais bon
		frameProcessed = true
		target.placeItem(selectedItem)
		selectedItem = null

func getSelectedItem():
	return selectedItem

func snapItemToCursor():
	var mousePosition = get_viewport().get_mouse_position()
	selectedItem.global_position = mousePosition

func displayPreview(): 
	pass
	# print("zzz")
