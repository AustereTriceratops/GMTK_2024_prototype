extends Node2D

@onready var mainNode = get_node('/root/main');

func _on_area_2d_body_entered(body):
	mainNode.increment_score(1);
	queue_free();
