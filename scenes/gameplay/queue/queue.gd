extends Node2D

signal item_picked_up

var ItemsPacks = {
	"bow":     preload("res://scenes/game_objects/item_instances/bow.tscn"),
	"hatchet": preload("res://scenes/game_objects/item_instances/hatchet.tscn"),
	"potion":  preload("res://scenes/game_objects/item_instances/potion.tscn"),
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_item_picked_up(item_node: Node2D):
	item_picked_up.emit(item_node)

func add_to_queue(item_name: String):
	var slot = _first_free()
	var pack = ItemsPacks.get(item_name, null)
	slot.item = pack

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
