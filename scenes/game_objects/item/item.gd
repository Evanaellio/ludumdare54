extends Node2D

## /../backpack/OccupiedTilemap
@onready var occupied_tilemap : TileMap = $"../../OccupiedTileMap"
var tile_nodes : Array[Node2D] = []

var tiles_occupied_by_me : Array[Vector2i] = []

const EMPTY = Vector2i(-1, -1)
const OCCUPIED = Vector2i(0, 0)

func _ready():
	print(occupied_tilemap)

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
	for tile_node in tile_nodes:
		var map_coords = get_map_coords_for_tile_node(tile_node)
		var status = occupied_tilemap.get_cell_atlas_coords(0, map_coords)
		if status == OCCUPIED:
			return true
	return false
		
func place_in_backpack() -> bool:
	if not check_occupied():
		for mine in tiles_occupied_by_me:
			occupied_tilemap.set_cell(0, mine, 0, EMPTY)
			tiles_occupied_by_me = []
		
		for tile_node in tile_nodes:
			var map_coords = get_map_coords_for_tile_node(tile_node)
			occupied_tilemap.set_cell(0, map_coords, 0, OCCUPIED)
			print("SET OCCUPIED MY CAPTAIN", map_coords)
			tiles_occupied_by_me.append(map_coords)
		return true
	else:
		return false
