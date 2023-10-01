extends Node2D


@export var item_type: String

@onready var backpack : Node2D = $"/root/Gameplay/Backpack"
@onready var occupied_tilemap : TileMap = $"/root/Gameplay/Backpack/OccupiedTileMap"
@onready var preview_tilemap : TileMap = $"/root/Gameplay/Backpack/PreviewTileMap"
@onready var selection_manager = $"/root/SelectionManager"

var is_electable_for_upgrade : bool = false

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
	if is_electable_for_upgrade:
		print("item.gd: TODO UPGRADE")
		backpack.removed_not_selected_upgrade(self)
		is_electable_for_upgrade = false
	else:
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


# ooooooooo.         .o.       ooooooooo.   ooooo ooooooooooooo oooooo   oooo 
# `888   `Y88.      .888.      `888   `Y88. `888' 8'   888   `8  `888.   .8'  
#  888   .d88'     .8"888.      888   .d88'  888       888        `888. .8'   
#  888ooo88P'     .8' `888.     888ooo88P'   888       888         `888.8'    
#  888`88b.      .88ooo8888.    888`88b.     888       888          `888'     
#  888  `88b.   .8'     `888.   888  `88b.   888       888           888      
# o888o  o888o o88o     o8888o o888o  o888o o888o     o888o         o888o     

const RARITY_COLORS : Array[Color] = [
	Color("ecf0f1"), # white
	Color("2ecc71"), # green
	Color("2980b9"), # blue
	Color("8e44ad"), # purple
	Color("f39c12")  # orange
]

var base_score: int = -1

## from 0 (common) to 4 (rare)
var rarity: int = -1

## compute score based on base_score and rarity
func get_score() -> int:
	return base_score * 2^rarity

func set_rarity(new_rarity: int):
	rarity = new_rarity
	if rarity >= 0 and rarity < RARITY_COLORS.size():
		var new_color = RARITY_COLORS[rarity]

## rarity can only increase
func incr_rarity() -> void:
	set_rarity(rarity + 1)

## compute base_score using side length
func _set_base_score() -> void:
	var used: Array[Vector2i] = %TileMap.get_used_cells(0)
	var empty_count: int = 0
	
	var neightbors: Array[Vector2i] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for cell in used:
		for neight in neightbors:
			var test_coord: Vector2i = cell + neight
			if used.find(test_coord) == -1:
				empty_count += 1
	base_score = empty_count

## setting base_score and rarity
func _ready() -> void:
	_set_base_score()
	set_rarity(0)

