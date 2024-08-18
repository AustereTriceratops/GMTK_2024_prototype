extends Button

signal pressed_idx(sibling_idx:int)

func _ready() -> void:
	pressed.connect(_on_pressed)
	
	
func _on_pressed():
	pressed_idx.emit(get_index())
	$"../../../..".on_level_select_idx_pressed(get_index())
