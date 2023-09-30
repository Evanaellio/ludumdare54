extends Node2D

@onready var occupied_tilemap : TileMap = $"OccupiedTileMap"
var clicking = false

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton && event.button_index == 1:
		if event.pressed:
			clicking = true
		if !event.pressed && clicking:
			get_node("/root/SelectionManager").dropItem(self)

func placeItem(item: Node2D):
	var item_tile = item.tile_nodes[0]
	var tile_coords = occupied_tilemap.to_local(item_tile.global_position)
	var map_coords = occupied_tilemap.local_to_map(tile_coords)
	var backpack_coords = occupied_tilemap.map_to_local(map_coords)
	var backpack_coords_global = occupied_tilemap.to_global(backpack_coords)
	
	item.global_translate(backpack_coords_global - item_tile.global_position)
