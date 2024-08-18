extends Node3D

@onready var mainNode = get_node('/root/main');

func _on_area_3d_body_entered(body: Node3D) -> void:
	mainNode.increment_score();
	queue_free();
