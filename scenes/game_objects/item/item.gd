extends Node2D

## /../backpack/OccupiedTilemap
@onready var occupied_tilemap : TileMap = $"../../backpack/OccupiedTileMap"
var tile_nodes : Array[Node2D] = []

const EMPTY = Vector2i(-1, -1)
const OCCUPIED = Vector2i(0, 0)

func on_click():
	# TODO : here, pickup the item and snap it to the mouse
	# Might need a global (autloaded) singleton to do that and make sure only one item is selected at once
	print("On CLICK from item tile")
	check_occupied()

func tile_ready(tile):
	tile_nodes.append(tile)
	
func check_occupied():
	for tile_node in tile_nodes:		
		var local_coords = occupied_tilemap.to_local(tile_node.global_position)
		var map_coords = occupied_tilemap.local_to_map(local_coords)
		var status = occupied_tilemap.get_cell_atlas_coords(0, map_coords)
		tile_node.set_error(status == OCCUPIED)
			
