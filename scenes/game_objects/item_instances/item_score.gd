class_name ItemScore extends Node
## Hold basic info and utilities on item scoring

## base used to compute score
## set using linked TileMap
var base_score: int = -1

## TileMap used to compute base_score
@onready var tile: TileMap = $Item.TileMap

## from 0 (common) to 5 (rare)
var rarity: int = -1

## compute score based on base_score and rarity
func get_score() -> int:
	return base_score * 2^rarity

## rarity can only increase
func incr_rarity() -> void:
	rarity += 1 

## compute base_score using side length
func _set_base_score() -> void:
	var used: Array[Vector2i] = tile.get_used_cells(0)
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
	rarity = 0

