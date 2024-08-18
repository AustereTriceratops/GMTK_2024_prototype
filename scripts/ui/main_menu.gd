extends Node


func on_level_select_idx_pressed(level_idx:int):
	print("Change to level %s" % level_idx)
	# Remove the current level
	get_child(0).visible = false

	if level_idx == 0:
		# Add the next level
		var next_level_resource = preload("res://scenes/level0.tscn").instantiate()
		get_tree().get_root().add_child(next_level_resource)
