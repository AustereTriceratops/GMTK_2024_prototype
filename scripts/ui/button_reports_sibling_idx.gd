extends Button

signal pressed_idx(sibling_idx:int)

func _ready() -> void:
	pressed.connect(_on_pressed)

func show_complete(isComplete: bool):
	get_child(0).visible = isComplete

func _on_pressed():
	pressed_idx.emit(get_index())
	$"../../../..".on_level_select_idx_pressed(get_index())
