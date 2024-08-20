extends Node

@onready var showhide_menu = $CanvasLayer/Control2
@onready var menu_scene = $CanvasLayer

func on_level_select_idx_pressed(level_idx:int):
	#print("Pushed button to change to level %s" % level_idx)
	# Remove the current level
	_on_toggle_main_menu_button_pressed() 
	
	for child in get_children():
		if child != menu_scene:
			child.queue_free() # delete other levels
	
	var next_level_resource
	match level_idx: # TODO update these to whatever the actual levels will be
		0:
			next_level_resource = preload("res://scenes/level0.tscn").instantiate()
		1:
			next_level_resource = preload("res://scenes/artonlylevel.tscn").instantiate()
		2:
			next_level_resource = preload("res://scenes/3dtestscene.tscn").instantiate()
		_:
			push_warning("No scene is assigned for this level select button")
			return
	add_child(next_level_resource) 

func _on_toggle_main_menu_button_pressed() -> void:
	showhide_menu.visible = !showhide_menu.visible
