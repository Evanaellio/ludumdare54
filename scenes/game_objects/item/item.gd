extends Node2D

@onready var occupied_tilemap : TileMap = $"/root/Gameplay/Backpack/OccupiedTileMap"
@onready var preview_tilemap : TileMap = $"/root/Gameplay/Backpack/PreviewTileMap"
var tile_nodes : Array[Node2D] = []

var tiles_occupied_by_me : Array[Vector2i] = []

const EMPTY = Vector2i(-1, -1)
const OCCUPIED = Vector2i(0, 0)

const PREVIEW_GREEN = Vector2i(0, 0)
const PREVIEW_RED = Vector2i(1, 0)

var last_preview_coord : Vector2i = Vector2i(-1, -1)

func _process(delta):
	if tile_nodes.size():
		var new_preview_coord = get_map_coords_for_tile_node(tile_nodes[0])
		if new_preview_coord != last_preview_coord:
			last_preview_coord = new_preview_coord
			check_occupied() # will update preview when we move to a new location

func on_click():
	# Might need a global (autloaded) singleton to do that and make sure only one item is selected at once
	get_node("/root/SelectionManager").selectItem(self)
	check_occupied()

func tile_ready(tile):
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
			preview_tilemap.set_cell(0, map_coords, 0, PREVIEW_RED)
			occupied = true
		else:
			preview_tilemap.set_cell(0, map_coords, 0, PREVIEW_GREEN)
	return occupied
	
func clear_previously_occupied_by_me():
	for mine in tiles_occupied_by_me:
		occupied_tilemap.set_cell(0, mine, 0, EMPTY)
		tiles_occupied_by_me = []

func place_in_backpack() -> bool:
	if not check_occupied():
		for tile_node in tile_nodes:
			var map_coords = get_map_coords_for_tile_node(tile_node)
			occupied_tilemap.set_cell(0, map_coords, 0, OCCUPIED)
			tiles_occupied_by_me.append(map_coords)
		clear_preview()
		return true
	else:
		return false

func clear_preview():
	preview_tilemap.clear()
