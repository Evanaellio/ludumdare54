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


# `start()` is called after pre_start and after the graphic transition ends.
func start():
	print("gameplay.gd: start() called")

	$queue.add_to_queue("bow")
	$queue.add_to_queue("hatchet")
	$queue.add_to_queue("potion")


func _process(delta):
	pass


func _on_queue_item_picked_up(item_node: Node2D):
	$backpack.add_child(item_node.duplicate())
