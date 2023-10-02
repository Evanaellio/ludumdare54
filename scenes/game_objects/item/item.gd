extends Node2D


@export var item_type: String

@onready var score_gui: Control = $"/root/Gameplay/ScoreGUI"
@onready var gameplay = $"/root/Gameplay"
@onready var backpack : Node2D = $"/root/Gameplay/Backpack"
@onready var queue = get_node("/root/Gameplay/Queue")
@onready var occupied_tilemap : TileMap = $"/root/Gameplay/Backpack/OccupiedTileMap"
@onready var preview_tilemap : TileMap = $"/root/Gameplay/Backpack/PreviewTileMap"
@onready var selection_manager = $"/root/SelectionManager"
@onready var halo_map = %HaloMap

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
	if selection_manager.selectedItem == null:
		noise()
		if is_electable_for_upgrade:
			backpack.removed_not_selected_upgrade(self)
			score_gui.decr_score(self.get_score())
			incr_rarity()
			score_gui.incr_score(self.get_score())
			is_electable_for_upgrade = false
			selection_manager.locked = false
			tween_upgrade.kill()
		else:
			score_gui.decr_score(self.get_score())
			selection_manager.selectItem(self, null, true)

func tile_ready(tile):
	tile.get_node("Area2D").input_pickable = false
	tile_nodes.append(tile)

func get_map_coords_for_tile_node(tile_node) -> Vector2i:
		var local_coords = occupied_tilemap.to_local(tile_node.global_position)
		var map_coords = occupied_tilemap.local_to_map(local_coords)
		return map_coords

# Handles preview
func check_occupied(lockedItems: Array[Node2D] = []) -> bool:
	clear_preview()
	var conflicts: Array[Node2D] = []
	var outOfBounds: bool = false
	var lockedItemConflict: bool = false
	for tile_node in tile_nodes:
		var map_coords = get_map_coords_for_tile_node(tile_node)
		var status = occupied_tilemap.get_cell_atlas_coords(0, map_coords)
		if status == OCCUPIED:
			if backpack.is_in_map_bounds(map_coords):
				preview_tilemap.set_cell(0, map_coords, 0, PREVIEW_RED)
				var item = backpack.get_item_lookup_at(map_coords)
				if item in lockedItems:
					lockedItemConflict = true
				if not item in conflicts:
					conflicts.push_front(item)
			else: 
				outOfBounds = true
		elif backpack.is_in_map_bounds(map_coords):
			preview_tilemap.set_cell(0, map_coords, 0, PREVIEW_GREEN)
	return outOfBounds || lockedItemConflict || conflicts.size() > 1

func get_conflicts() -> Array[Node2D]:
	var conflicts: Array[Node2D] = []
	for tile_node in tile_nodes:
		var map_coords = get_map_coords_for_tile_node(tile_node)
		var status = occupied_tilemap.get_cell_atlas_coords(0, map_coords)
		if status == OCCUPIED:
			if backpack.is_in_map_bounds(map_coords):
				var item = backpack.get_item_lookup_at(map_coords)
				if not item in conflicts:
					conflicts.push_front(item)
	return conflicts

func clear_previously_occupied_by_me():
	for mine in tiles_occupied_by_me:
		occupied_tilemap.set_cell(0, mine, 0, EMPTY)
		backpack.set_item_lookup_at(null, tiles_occupied_by_me)
		tiles_occupied_by_me = []

func place_in_backpack() -> Node2D:
	var conflicts = get_conflicts()
	if conflicts.size() < 2:
		var swappedItem: Node2D = null
		if conflicts.size() == 1:
			swappedItem = conflicts[0]
			get_node("/root/SelectionManager").forceSelectItem(swappedItem, null)
		for tile_node in tile_nodes:
			var map_coords = get_map_coords_for_tile_node(tile_node)
			occupied_tilemap.set_cell(0, map_coords, 0, OCCUPIED)
			tiles_occupied_by_me.append(map_coords)
		enable_collisions()
		clear_preview()
		noise()
		return swappedItem
	else:
		return null

func disable_collisions():
	for tile_node in tile_nodes:
		tile_node.get_node("Area2D").input_pickable = false

func enable_collisions():
	for tile_node in tile_nodes:
		tile_node.get_node("Area2D").input_pickable = true

func clear_preview():
	preview_tilemap.clear()

func custom_rotate(radians: float) -> void:
	self.rotate(radians)
	match item_type:
		"MagicPotion":
			var liquid: Sprite2D = $"./Liquid"
			liquid.rotate(-radians)
		"MagicMorningJJ":
			var jj: Sprite2D = $"./JJ"
			jj.rotate(-radians)
			var rot = absf(fmod(jj.get_rotation(), 2*PI))
			# aesthetic flip when item is rotated up
			if (0.75*PI < rot) && (rot < 1.25*PI):
				jj.flip_h = true
			else:
				jj.flip_h = false

func noise():
	$pickupSfx.play()

# ooooooooo.         .o.       ooooooooo.   ooooo ooooooooooooo oooooo   oooo 
# `888   `Y88.      .888.      `888   `Y88. `888' 8'   888   `8  `888.   .8'  
#  888   .d88'     .8"888.      888   .d88'  888       888        `888. .8'   
#  888ooo88P'     .8' `888.     888ooo88P'   888       888         `888.8'    
#  888`88b.      .88ooo8888.    888`88b.     888       888          `888'     
#  888  `88b.   .8'     `888.   888  `88b.   888       888           888      
# o888o  o888o o88o     o8888o o888o  o888o o888o     o888o         o888o     

var tween_upgrade : Tween = null

const RARITY_COLORS : Array[Color] = [
	Color("ecf0f1"), # white
	Color("2ecc71"), # green
	Color("2980b9"), # blue
	Color("8e44ad"), # purple
	Color("f39c12"),  # orange
	Color("2c3e50")  # almost black, endgame item
]

var base_score: int = -1

## from 0 (common) to 4 (rare)
var rarity: int = -1

## compute score based on base_score and rarity
func get_score() -> int:
	return base_score * (rarity * rarity * rarity * rarity * rarity)

func set_rarity(new_rarity: int):
	rarity = new_rarity
	if rarity >= 0 and rarity < RARITY_COLORS.size():
		var new_color = RARITY_COLORS[rarity]
		set_color(new_color)
	
	queue.rarity_progression = max(queue.rarity_progression, new_rarity)
	
	if new_rarity == 5: # After a full line of orange, the player wins !
		gameplay.win_game()

func set_color(color : Color):
	halo_map.modulate = color

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

func animate_upgrade():
	tween_upgrade = create_tween().set_loops()
	var next_rarity_color : Color = RARITY_COLORS[rarity + 1]
	var next_rarity_transparent = next_rarity_color
	next_rarity_transparent.a = 0
	
	tween_upgrade.tween_property(halo_map, "modulate", next_rarity_color, 0.4)
	tween_upgrade.tween_interval(0.3)
	tween_upgrade.tween_property(halo_map, "modulate", next_rarity_transparent, 0.4)
	
	tween_upgrade.play()

func animate_upgrade_component(local_position: Vector2):
	var tween_component = create_tween().set_parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween_component.tween_property(self, "scale", Vector2(0, 0), 0.68)
	tween_component.tween_property(self, "global_position", local_position, 0.7)
	tween_component.tween_property(self, "rotation_degrees", self.rotation_degrees + 180, 0.7)
	tween_component.connect("finished", on_upgrade_component_finished)
	tween_component.play()
	
	
func on_upgrade_component_finished():
	clear_previously_occupied_by_me()
	queue_free()
	
	
