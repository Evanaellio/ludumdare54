extends Node2D

@onready var queue = $"/root/Gameplay/Queue"
@onready var score_gui: Control = $"/root/Gameplay/ScoreGUI"

@onready var occupied_tilemap : TileMap = %OccupiedTileMap

@onready var first_map_coords : Vector2i
@onready var last_map_coords : Vector2i

const HEIGHT: int = 10
const WIDTH: int = 12

var clicking : bool = false
var item_lookup: Array[Node2D] = []

var waiting_upgrade_selected : bool = false
var upgradable_items : Array[Node2D] = []

func get_map_coords_for_node(node: Node2D) -> Vector2i:
		var local_coords = occupied_tilemap.to_local(node.global_position)
		var map_coords = occupied_tilemap.local_to_map(local_coords)
		return map_coords

func _ready() -> void:
	first_map_coords = get_map_coords_for_node(%FirstCell)
	last_map_coords = get_map_coords_for_node(%LastCell)
	
	item_lookup.resize(HEIGHT * WIDTH)
	item_lookup.fill(null)

func is_in_map_bounds(map_coords: Vector2i):
	return first_map_coords.x <= map_coords.x \
		and map_coords.x <= last_map_coords.x \
		and first_map_coords.y <= map_coords.y \
		and map_coords.y <= last_map_coords.y 

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton && event.button_index == 1:
		if event.pressed:
			clicking = true
		if !event.pressed && clicking:
			get_node("/root/SelectionManager").dropItem(self)

func get_item_lookup_at(coord: Vector2i) -> Node2D:
	return item_lookup[coord.x + coord.y * WIDTH]

func set_item_lookup_at(item: Node2D, coords: Array[Vector2i]) -> void:
	for c in coords:
		item_lookup[c.x + c.y * WIDTH] = item

func add_item_to_lookup(item: Node2D) -> Array[int]:
	set_item_lookup_at(item, item.tiles_occupied_by_me)
	
	var stained_lines: Array[int] = []
	for c in item.tiles_occupied_by_me:
		if stained_lines.find(c.y) == -1:
			stained_lines.append(c.y)
	
	return stained_lines

func get_completed_lines(stained_lines: Array[int]) -> Array[int]:
	var completed_lines: Array[int] = []
	for l in stained_lines:
		var complete_line: bool = true
		var line_rarity: int = -1
		for c in range(0, WIDTH):
			var item_found = get_item_lookup_at(Vector2i(c, l))
			if item_found == null:
				complete_line = false
				break
			elif line_rarity == -1:
				line_rarity = item_found.rarity
			elif line_rarity != item_found.rarity:
				complete_line = false
				break
		if complete_line:
			completed_lines.append(l)
	return completed_lines

func get_items_from_completed_lines(completed_lines: Array[int]) -> Array[Node2D]:
	var items: Array[Node2D] = []
	
	for l in completed_lines:
		for c in range(0, WIDTH):
			var item = get_item_lookup_at(Vector2i(c, l))
			if items.find(item) == -1:
				items.append(item)
	
	return items

func removed_not_selected_upgrade(selected: Node2D) -> void:
	%UpgradeSfx.play()
	for i in upgradable_items:
		if i != selected:
			i.animate_upgrade_component(selected.global_position)
			score_gui.decr_score(i.get_score())
	upgradable_items = []
	waiting_upgrade_selected = false

func snap_item_to_grid(item: Node2D) -> void:
	var item_tile = item.tile_nodes[0]
	var tile_coords = occupied_tilemap.to_local(item_tile.global_position)
	var map_coords = occupied_tilemap.local_to_map(tile_coords)
	var backpack_coords = occupied_tilemap.map_to_local(map_coords)
	var backpack_coords_global = occupied_tilemap.to_global(backpack_coords)
	
	item.global_translate(backpack_coords_global - item_tile.global_position)

func canItemBePlaced(item: Node2D) -> bool:
	return not item.check_occupied(upgradable_items)

func placeItem(item: Node2D) -> Node2D:
	var swappedItem: Node2D = item.place_in_backpack()
	
	# handle score
	score_gui.incr_score(item.get_score())
	if swappedItem != null:
		score_gui.decr_score(swappedItem.get_score())

	snap_item_to_grid(item)
	queue.item_taken_from_queue()
	var stained_lines: Array[int] = add_item_to_lookup(item)
	var completed_lines: Array[int] = get_completed_lines(stained_lines)
	if !completed_lines.is_empty():
		upgradable_items = get_items_from_completed_lines(completed_lines)
		print(upgradable_items)
		waiting_upgrade_selected = true
		for i in upgradable_items:
			i.is_electable_for_upgrade = true
			i.animate_upgrade()
			SelectionManager.locked = true
	return swappedItem
