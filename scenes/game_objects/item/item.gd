extends Node2D


@export var item_type: String

@onready var backpack = $"/root/Gameplay/Backpack"
@onready var occupied_tilemap : TileMap = $"/root/Gameplay/Backpack/OccupiedTileMap"
@onready var preview_tilemap : TileMap = $"/root/Gameplay/Backpack/PreviewTileMap"
@onready var selection_manager = $"/root/SelectionManager"
@onready var backpack : Node2D = $"/root/Gameplay/Backpack"

var tile_nodes : Array[Node2D] = []

var tiles_occupied_by_me : Array[Vector2i] = []

const EMPTY = Vector2i(-1, -1)
const OCCUPIED = Vector2i(0, 0)

const PREVIEW_GREEN = Vector2i(0, 0)
const PREVIEW_RED = Vector2i(1, 0)

var last_preview_coord : Vector2i = Vector2i(-1, -1)

func display_preview():
	var new_preview_coord = get_map_coords_for_tile_node(tile_nodes[0])
	if new_preview_coord != last_preview_coord:
		last_preview_coord = new_preview_coord
		check_occupied() # will update preview when we move to a new location

func on_click():
	selection_manager.selectItem(self)

func tile_ready(tile):
	tile.get_node("Area2D").input_pickable = false
	tile_nodes.append(tile)

func get_map_coords_for_tile_node(tile_node) -> Vector2i:
		var local_coords = occupied_tilemap.to_local(tile_node.global_position)
		var map_coords = occupied_tilemap.local_to_map(local_coords)
		return map_coords

func check_occupied() -> bool:
	clear_preview()
	var occupied = false
	for tile_node in tile_nodes:
		var map_coords = get_map_coords_for_tile_node(tile_node)
		var status = occupied_tilemap.get_cell_atlas_coords(0, map_coords)
		if status == OCCUPIED:
			occupied = true
			if backpack.is_in_map_bounds(map_coords):
				preview_tilemap.set_cell(0, map_coords, 0, PREVIEW_RED)
		elif backpack.is_in_map_bounds(map_coords):
			preview_tilemap.set_cell(0, map_coords, 0, PREVIEW_GREEN)
	return occupied
	
func clear_previously_occupied_by_me():
	for mine in tiles_occupied_by_me:
		occupied_tilemap.set_cell(0, mine, 0, EMPTY)
		backpack.set_item_lookup_at(null, tiles_occupied_by_me)
		tiles_occupied_by_me = []

func place_in_backpack() -> bool:
	if not check_occupied():
		for tile_node in tile_nodes:
			var map_coords = get_map_coords_for_tile_node(tile_node)
			occupied_tilemap.set_cell(0, map_coords, 0, OCCUPIED)
			tiles_occupied_by_me.append(map_coords)
		enable_collisions()
		clear_preview()
		return true
	else:
		return false

func disable_collisions():
	for tile_node in tile_nodes:
		tile_node.get_node("Area2D").input_pickable = false

func enable_collisions():
	for tile_node in tile_nodes:
		tile_node.get_node("Area2D").input_pickable = true

func clear_preview():
	preview_tilemap.clear()
