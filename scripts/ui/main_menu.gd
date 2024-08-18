extends Node

@onready var showhide_menu = $CanvasLayer/Control2
@onready var menu_scene = $CanvasLayer

func on_level_select_idx_pressed(level_idx:int):
	print("Change to level %s" % level_idx)
	# Remove the current level
	#get_child(0).visible = false
	_on_toggle_main_menu_button_pressed() 
	
	for child in get_children():
		if child != menu_scene:
			child.queue_free() # delete other levels
	
	var next_level_resource
	match level_idx:
		0:
			next_level_resource = preload("res://scenes/level0.tscn").instantiate()
		1:
			next_level_resource = preload("res://scenes/artonlylevel.tscn").instantiate()
		1:
			next_level_resource = preload("res://scenes/3dtestscene.tscn").instantiate()
		_:
			return
	add_child(next_level_resource) #get_tree().get_root().


func _on_toggle_main_menu_button_pressed() -> void:
	showhide_menu.visible = !showhide_menu.visible
