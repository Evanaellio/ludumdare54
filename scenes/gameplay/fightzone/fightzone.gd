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
@onready var next_quest_timer: Timer = $NextQuestTimer

@onready var score_gui: Control = $"/root/Gameplay/ScoreGUI"

@onready var ItemsPacks = SelectionManager.ItemsPacks
@onready var Queue = get_node("/root/Gameplay/Queue")

signal found_loot

enum States {WALK, FIGHT}

var state = States.WALK
var boosted = false

var requestItemType: String

# Called when the node enters the scene tree for the first time.
func _ready():
	quest_progress.hide()
	quest_gui.hide()
	boost_remaining.hide()
	fight_gui.hide()

	next_loot()
	next_fight()
	next_quest()
	# boost()

	%AnimationPlayer.play("npc")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	boost_remaining.value = boost_timer.time_left / boost_timer.wait_time
	loot_progress.value = 1 - loot_timer.time_left / loot_timer.wait_time
	quest_progress.value = quest_timer.time_left / quest_timer.wait_time
	
	if state == States.WALK:
		background.get_node("ParallaxBackground").scroll_offset += Vector2(-delta * 8, 0)
	
	var rar = Queue.rarity_mult * Queue.temp_rarity_mult
	loot_progress.get_node("Rarity").text = "Rarity: " + str(rar) + "X"

# Start timer to next loot, timer can be paused during fights
func next_loot():
	var wait_length = 5 + randi_range(-2, 3)
	loot_timer.start(wait_length)

func _on_loot_timer_timeout():
	found_loot.emit()
	next_loot()

# Start timer to next fight
func next_fight():
	var wait_length = 14.5 + randi_range(-5, 5)
	next_fight_timer.start(wait_length)

func _on_next_fight_timer_timeout():
	state = States.FIGHT
	fight_gui.show()
	loot_timer.paused = true
	var fight_length = 3 + randi_range(-1, 2)
	fight_timer.start(fight_length)
	%AnimationPlayer.play("attac")

func _on_fight_timer_timeout():
	state = States.WALK
	fight_gui.hide()
	loot_timer.paused = false
	%AnimationPlayer.play("npc")
	next_fight()

# When NPC receives requested item
func boost(level: int):
	var boost_length = 20
	boost_timer.start(boost_length)
	boosted = true
	Queue.temp_rarity_mult = level
	boost_remaining.show()

func _on_boost_timer_timeout():
	boosted = false
	Queue.temp_rarity_mult = 1
	boost_remaining.hide()
	next_quest()

# Start timer to next quest
func next_quest():
	var wait_length = 5 + randi_range(-1, 2)
	next_quest_timer.start(wait_length)

func _on_next_quest_timer_timeout():
	start_quest()

func start_quest():
	var request = ItemsPacks.keys()[randi() % (ItemsPacks.keys().size() - 1)]
	var pack: PackedScene = ItemsPacks.get(request)
	var item = pack.instantiate()
	
	requestItemType = item.get_node("Item").item_type
	print("requesting item : " + requestItemType)
	
	quest_slot.add_child(item)
	
	var quest_length = 30
	quest_timer.start(quest_length)
	quest_progress.show()
	quest_gui.show()

func _on_quest_timer_timeout():
	cancel_quest()

func cancel_quest():
	quest_progress.hide()
	quest_gui.hide()
	quest_timer.stop()

	requestItemType = ""

	for _i in quest_slot.get_children():
		_i.queue_free()

	if not boosted:
		print("sad :(")
		next_quest()

var clicking = false
func _on_deposit_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton && event.button_index == 1:
		if event.pressed :
			clicking = true
		if !event.pressed && clicking:
			var selected: Node2D = SelectionManager.selectedItem
			if selected != null and quest_gui.visible:
				var nodeName = selected.item_type
				if requestItemType == nodeName:
					var score = selected.get_score()
					score_gui.incr_score(score)
					SelectionManager.destroyItem()
					if SelectionManager.selectedItemSource != null:
						# if item taken directly from queue, release queue slot
						Queue.item_taken_from_queue()
					boost(selected.rarity + 2)
					
					cancel_quest()

func _on_deposit_area_mouse_exited():
	clicking = false
