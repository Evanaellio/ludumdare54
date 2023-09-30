class_name ItemScore extends Node

var base_score: int = -1
var rarity: int = -1

@onready var tile: TileMap = $Item.TileMap

func get_score() -> int:
	return base_score * 2^rarity

func incr_rarity() -> void:
	rarity += 1 

func _ready() -> void:
	var used: Array[Vector2i] = tile.get_used_cells(0)
	var empty_count: int = 0
	
	var neightbors: Array[Vector2i] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for cell in used:
		for neight in neightbors:
			var test_coord: Vector2i = cell + neight
			if used.find(test_coord) == -1:
				empty_count += 1
	
	base_score = empty_count
	rarity = 0

