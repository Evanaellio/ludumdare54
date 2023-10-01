extends Node2D

signal item_picked_up

@onready var ItemsPacks = get_node("/root/SelectionManager").ItemsPacks

var active_slot: Node2D = null
var selected_oite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_item_picked_up(slot_node: Node2D):
	active_slot = slot_node
	var selected_item = slot_node.item_ptr
	var pack = slot_node.item_pack
	active_slot.item = pack
	item_picked_up.emit(selected_item)

func item_placed_backpack():
	deactivateSlot(false)
	var slots = $Items.get_children()
	for i in slots.size() - 1:
		if slots[i].item == null and not slots[i + 1].item == null:
			slots[i].item = slots[i+1].item
			slots[i+1].item = null

func unselectItem(item: Node2D):
	get_node("/root/SelectionManager").destroyItem()
	deactivateSlot(true)

func deactivateSlot(revert: bool):
	if active_slot != null:
		if revert:
			active_slot.item_placed_back()
		else: 
			active_slot.item_dropped()
		active_slot = null

func add_to_queue(item_name: String):
	var slot = _first_free()
	if slot != null:
		var pack = ItemsPacks.get(item_name, null)
		slot.item = pack
	else:
		print("queue is full!")

func add_random_to_queue():
	var n = ItemsPacks.keys()[randi() % ItemsPacks.keys().size()]
	add_to_queue(n)

func has_space() -> bool:
	return _first_free() != null

func _first_free() -> Node2D:
	if $Items/slot1.item == null:
		return $Items/slot1
	if $Items/slot2.item == null:
		return $Items/slot2
	if $Items/slot3.item == null:
		return $Items/slot3
	if $Items/slot4.item == null:
		return $Items/slot4
	if $Items/slot5.item == null:
		return $Items/slot5
	return null
