extends Node2D

signal item_picked_up

@onready var ItemsPacks = SelectionManager.ItemsPacks

@onready var alert_player: AnimationPlayer = $"./AlertPlayer"

# Max item rarity given in a quest
var rarity_progression = 0
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

func update_warning():
	if %slot5.item:
		%AnimationPlayerSlotWarning.play("warning")
		#alert_player.play("queue_alert")
		get_node("/root/Gameplay/AudioStreamPlayer").stop()
		$AudioStreamPlayer.play()
	else:
		%AnimationPlayerSlotWarning.play("RESET")
		if not get_node("/root/Gameplay/AudioStreamPlayer").playing:
			get_node("/root/Gameplay/AudioStreamPlayer").play()
		$AudioStreamPlayer.stop()
		#alert_player.stop()

func item_taken_from_queue():
	deactivateSlot(false)
	var slots = $Items.get_children()
	for i in slots.size() - 1:
		if slots[i].item == null and not slots[i + 1].item == null:
			slots[i].item = slots[i+1].item
			slots[i].rarity = slots[i+1].rarity
			slots[i+1].item = null
	update_warning()

func unselectItem(item: Node2D):
	get_node("/root/SelectionManager").destroyItem()
	deactivateSlot(true)
	update_warning()

func deactivateSlot(revert: bool):
	if active_slot != null:
		if revert:
			active_slot.item_placed_back()
		else: 
			active_slot.item_dropped()
		active_slot = null
	update_warning()

func add_to_queue(item_name: String, rarity: int):
	var slot = _first_free()	
	if slot != null:
		var pack = ItemsPacks.get(item_name, null)
		slot.item = pack
		slot.rarity = rarity
		update_warning()
	else:
		$"/root/Gameplay".lose_game()
		$AudioStreamPlayer.queue_free()

func add_random_to_queue():
	add_to_queue(rand_item(), _rand_rarity(rarity_mult * temp_rarity_mult))
	update_warning()

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

func _rand_rarity(mult: int):
	var weights: Array[Dictionary] = [
		{"value": 0, "weight": 100.0},
		{"value": 1, "weight": 40.0 * mult},
		{"value": 2, "weight": 15.0 * mult},
		{"value": 3, "weight": 5.0 * mult},
	]
	var weighted_rand_rarity = RngUtils.array_with_weighted(weights)[0].value
	return min(rarity_progression, weighted_rand_rarity)

func _first_free() -> Node2D:
	if %slot1.item == null:
		return %slot1
	if %slot2.item == null:
		return %slot2
	if %slot3.item == null:
		return %slot3
	if %slot4.item == null:
		return %slot4
	if %slot5.item == null:
		return %slot5
	return null

# I miss arrays
func items_amount() -> int:
	if %slot1.item == null:
		return 0
	if %slot2.item == null:
		return 1
	if %slot3.item == null:
		return 2
	if %slot4.item == null:
		return 3
	if %slot5.item == null:
		return 4
	return 5
