extends Node3D

func _ready():
	rotate_z(randf())
	rotate_x(randf())

func _on_area_3d_body_entered(_body: Node3D) -> void:
	Globals.increment_score();
	queue_free();
