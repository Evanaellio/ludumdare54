extends Node

var elapsed = 0


# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.
func pre_start(params):
	var cur_scene: Node = get_tree().current_scene
	print("Scene loaded: ", cur_scene.name, " (", cur_scene.scene_file_path, ")")
	if params:
		for key in params:
			var val = params[key]
			printt("", key, val)
	$PauseLayer.visible = true
	
	$AudioStreamPlayer.play()

	$Fightzone.connect("found_loot", Callable($Queue, "add_random_to_queue").bind())

# `start()` is called after pre_start and after the graphic transition ends.
func start():
	print("gameplay.gd: start() called")

	$Queue.add_random_to_queue()
	$Queue.add_random_to_queue()

func win_game():
	# TODO : lock UI, do some logic, go back to menu etc...
	%WinScreen.visible = true
	$Fightzone.stop()

func lose_game():
	# TODO : lock UI, do some logic, go back to menu etc...
	%LoseScreen.visible = true
	$Fightzone.stop()

func _on_queue_item_picked_up(item_node: Node2D):
	var selectionManager = get_node("/root/SelectionManager")
	if selectionManager.selectItem(item_node.get_node("Item"), $Queue):
		$Backpack.add_child(item_node)

func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()
	
func restart():
	var params = {
		"show_progress_bar": true,
	}
	Game.change_scene_to_file("res://scenes/gameplay/gameplay.tscn", params)

