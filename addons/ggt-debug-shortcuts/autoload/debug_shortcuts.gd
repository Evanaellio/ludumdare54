extends Node


func _ready():
	# Remove debug shortcuts on release builds
	if not OS.is_debug_build():
		queue_free()
