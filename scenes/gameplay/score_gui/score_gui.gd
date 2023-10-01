extends Control

var score: int = 0
var backpack: int = 0

@onready var score_val: Label = $"./VBoxContainer/Score/Value"

func update_score() -> void:
	score_val.text = "%05d" % score

func incr_score(val: int) -> void:
	score += val
	update_score()

func decr_score(val: int) -> void:
	score -= val
	if score < 0:
		score = 0
	update_score()

func _ready():
	update_score()

func _process(delta):
	pass
