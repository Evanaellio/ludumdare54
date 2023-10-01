extends Node2D

signal item_picked_up

@onready var ItemsPacks = get_node("/root/SelectionManager").ItemsPacks

# Max item rarity given in a quest
var rarity_progression = 0

# starting at : 1 out of X 
# then : rarity_mult out of X
const RARITY_CHANCES = [ 
	1,   # common
	10,
	25,
	50,
	100  # rare
]
var rarity_mult = 1 # increase with time
var temp_rarity_mult = 1 # increase with boost

var active_slot: Node2D = null
var selected_oite

func _on_item_picked_up(slot_node: Node2D):
	active_slot = slot_node
	var selected_item = slot_node.item_ptr
	var rarity = slot_node.rarity
	var pack = slot_node.item_pack
	active_slot.item = pack
	active_slot.rarity = rarity
	item_picked_up.emit(selected_item)

func item_taken_from_queue():
	deactivateSlot(false)
	var slots = $Items.get_children()
	for i in slots.size() - 1:
		if slots[i].item == null and not slots[i + 1].item == null:
			slots[i].item = slots[i+1].item
			slots[i].rarity = slots[i+1].rarity
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

func add_to_queue(item_name: String, rarity: int):
	var slot = _first_free()
	if slot != null:
		var pack = ItemsPacks.get(item_name, null)
		slot.item = pack
		slot.rarity = rarity
	else:
		$"/root/Gameplay".lose_game()

func add_random_to_queue():
	add_to_queue(rand_item(), _rand_rarity(rarity_mult * temp_rarity_mult))

func rand_item():
	var weights: Array[Dictionary] = [
		{"value": "apple", "weight": 10.0},
		{"value": "armor", "weight": 10.0},
		{"value": "arrow", "weight": 10.0},
		{"value": "boomerang", "weight": 10.0},
		{"value": "bow", "weight": 10.0},
		{"value": "hatchet", "weight": 10.0},
		{"value": "key", "weight": 10.0},
		{"value": "sword", "weight": 10.0},
		{"value": "magic_potion", "weight": 10.0},
		{"value": "magic_morning_jj", "weight": 3.0}
	]
	return RngUtils.array_with_weighted(weights)[0].value

func has_space() -> bool:
	return _first_free() != null

func _rand_rarity(mutl: int):
	var maxRarity = RARITY_CHANCES.size() - 1
	for i in maxRarity:
		if randi_range(1, RARITY_CHANCES[maxRarity-i]) <= mutl:
			return maxRarity-i
	return 0

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

# I miss arrays
func items_amount() -> int:
	if $Items/slot1.item == null:
		return 0
	if $Items/slot2.item == null:
		return 1
	if $Items/slot3.item == null:
		return 2
	if $Items/slot4.item == null:
		return 3
	if $Items/slot5.item == null:
		return 4
	return 5
