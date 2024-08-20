extends Node

@onready var showhide_menu = $CanvasLayer/Control2
@onready var menu_scene = $CanvasLayer
@export var level_button_parent : Node

func _ready() -> void:
	update_star_completion()
	Globals.current_level_complete.connect(on_level_complete)

func on_level_complete(current_level):
	remove_all_levels()
	showhide_menu.visible = true
	update_star_completion()
	$CanvasLayer/AudioStreamPlayer/ExplosionSound.play()
	$CanvasLayer/AudioStreamPlayer/LevelCompleteSound.play()

func remove_all_levels():
	for child in get_children():
		if child != menu_scene:
			child.queue_free() # delete other levels

func on_level_select_idx_pressed(level_idx:int):
	#print("Pushed button to change to level %s" % level_idx)
	# Remove the current level
	Globals.reset_player()
	
	_on_toggle_main_menu_button_pressed() 
	
	remove_all_levels()
	
	var next_level_resource
	match level_idx: # TODO update these to whatever the actual levels will be
		0:
			next_level_resource = preload("res://scenes/level0.tscn").instantiate()
		1:
			next_level_resource = preload("res://scenes/levels/level_1.tscn").instantiate()
		2:
			next_level_resource = preload("res://scenes/level2.tscn").instantiate()
		_:
			push_warning("No scene is assigned for this level select button")
			return
	Globals.current_level = level_idx
	add_child(next_level_resource) 

func _on_toggle_main_menu_button_pressed() -> void:
	showhide_menu.visible = !showhide_menu.visible
	update_star_completion()

func update_star_completion():
	var buttons = level_button_parent.get_children()
	for i in range(buttons.size()):
		buttons[i].show_complete(Globals.level_complete[i])
