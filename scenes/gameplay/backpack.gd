extends Node2D

@onready var occupied_tilemap : TileMap = %OccupiedTileMap


@onready var first_map_coords : Vector2i
@onready var last_map_coords : Vector2i

var clicking = false

func get_map_coords_for_node(node: Node2D) -> Vector2i:
		var local_coords = occupied_tilemap.to_local(node.global_position)
		var map_coords = occupied_tilemap.local_to_map(local_coords)
		return map_coords

func _ready():
	first_map_coords = get_map_coords_for_node(%FirstCell)
	last_map_coords = get_map_coords_for_node(%LastCell)
	
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

func placeItem(item: Node2D) -> bool:
	if item.place_in_backpack():
		var item_tile = item.tile_nodes[0]
		var tile_coords = occupied_tilemap.to_local(item_tile.global_position)
		var map_coords = occupied_tilemap.local_to_map(tile_coords)
		var backpack_coords = occupied_tilemap.map_to_local(map_coords)
		var backpack_coords_global = occupied_tilemap.to_global(backpack_coords)
		
		item.global_translate(backpack_coords_global - item_tile.global_position)
		return true
	else:
		return false
