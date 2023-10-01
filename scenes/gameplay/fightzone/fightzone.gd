extends Node2D

@onready var loot_timer: Timer = $LootTimer
@onready var loot_progress: ProgressBar = $GUI/LootProgressBar
@onready var boost_timer: Timer = $BoostTimer
@onready var boost_remaining: ProgressBar = $GUI/BoostProgressBar
@onready var fight_gui: Control = $GUI/Fight

@onready var fight_timer: Timer = $FightTimer
@onready var next_fight_timer: Timer = $NextFightTimer

@onready var background = $SubViewportContainer/SubViewport/TestBiome

@onready var quest_gui: Control = $GUI/Query
@onready var quest_slot: Control = $GUI/Query/ItemViewport/SubViewport/ItemAttach
@onready var quest_progress: ProgressBar = $GUI/QueryProgressBar
@onready var quest_timer: Timer = $QuestTimer

signal found_loot

enum States {WALK, FIGHT}

var state = States.WALK
var boosted = false

# Called when the node enters the scene tree for the first time.
func _ready():
	quest_progress.hide()
	quest_gui.hide()
	fight_gui.hide()

	next_loot()
	next_fight()
	next_quest()
	# boost()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	boost_remaining.value = boost_timer.time_left / boost_timer.wait_time
	loot_progress.value = 1 - loot_timer.time_left / loot_timer.wait_time
	quest_progress.value = quest_timer.time_left / quest_timer.wait_time
	
	if state == States.WALK:
		background.get_node("ParallaxBackground").scroll_offset += Vector2(-delta * 8, 0)
	
# Start timer to next loot, timer can be paused during fights
func next_loot():
	var wait_length = 5 + randi_range(-2, 3)
	loot_timer.start(wait_length)

func _on_loot_timer_timeout():
	found_loot.emit()
	next_loot()

# Start timer to next fight
func next_fight():
	var wait_length = 15 + randi_range(-5, 5)
	next_fight_timer.start(wait_length)

func _on_next_fight_timer_timeout():
	state = States.FIGHT
	fight_gui.show()
	loot_timer.paused = true
	var fight_length = 3 + randi_range(-2, 2)
	fight_timer.start(fight_length)

func _on_fight_timer_timeout():
	state = States.WALK
	fight_gui.hide()
	loot_timer.paused = false
	next_fight()

# When NPC receives requested item
func boost():
	var boost_length = 10
	boost_timer.start(boost_length)
	boosted = true
	boost_remaining.show()

func _on_boost_timer_timeout():
	boosted = false
	boost_remaining.hide()

func next_quest():
	var request = "bow"
	var pack: PackedScene = load("res://scenes/game_objects/item_instances/" + request +".tscn")
	var item = pack.instantiate()
	
	quest_slot.add_child(item)
	
	var quest_length = 30
	quest_timer.start(quest_length)
	quest_progress.show()
	quest_gui.show()

func _on_quest_timer_timeout():
	quest_progress.hide()
	quest_gui.hide()
